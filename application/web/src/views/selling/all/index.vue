<template>
  <div class="container">
    <el-alert
      type="success"
    >
      <p>Account_ID: {{ accountId }}</p>
      <p>Username: {{ userName }}</p>
      <p>Balance: {{ balance }} </p>
    </el-alert>
    <div v-if="sellingList.length==0" style="text-align: center;">
      <el-alert
        title="Can't find data"
        type="warning"
      />
    </div>
    <el-row v-loading="loading" :gutter="20">
      <el-col v-for="(val,index) in sellingList" :key="index" :span="6" :offset="1">
        <el-card class="all-card">
          <div slot="header" class="clearfix">
            <span>{{ val.sellingStatus }}</span>
            <el-button v-if="roles[0] !== 'admin'&&(val.seller===accountId||val.buyer===accountId)&&val.sellingStatus!=='Finish'&&val.sellingStatus!=='Expired'&&val.sellingStatus!=='Cancelled'" style="float: right; padding: 3px 0" type="text" @click="updateSelling(val,'cancelled')">Cancel</el-button>
            <el-button v-if="roles[0] !== 'admin'&&val.seller===accountId&&val.sellingStatus==='In Delivery'" style="float: right; padding: 3px 8px" type="text" @click="updateSelling(val,'done')">Confirmed Paid</el-button>
            <el-button v-if="roles[0] !== 'admin'&&val.sellingStatus==='Sale'&&val.seller!==accountId" style="float: right; padding: 3px 0" type="text" @click="createSellingByBuy(val)">Buy</el-button>
          </div>
          <div class="item">
            <el-tag>Property_ID: </el-tag>
            <span>{{ val.objectOfSale }}</span>
          </div>
          <div class="item">
            <el-tag type="success">Seller_ID: </el-tag>
            <span>{{ val.seller }}</span>
          </div>
          <div class="item">
            <el-tag type="danger">Price: </el-tag>
            <span>INR {{ val.price }} </span>
          </div>
          <div class="item">
            <el-tag type="warning">Validity Period: </el-tag>
            <span>{{ val.salePeriod }}  </span>
          </div>
          <div class="item">
            <el-tag type="info">Creation Time: </el-tag>
            <span>{{ val.createTime }}</span>
          </div>
          <div class="item">
            <el-tag>Buyer_ID: </el-tag>
            <span v-if="val.buyer===''">Waiting</span>
            <span>{{ val.buyer }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import { querySellingList, createSellingByBuy, updateSelling } from '@/api/selling'

export default {
  name: 'AllSelling',
  data() {
    return {
      loading: true,
      sellingList: []
    }
  },
  computed: {
    ...mapGetters([
      'accountId',
      'roles',
      'userName',
      'balance'
    ])
  },
  created() {
    querySellingList().then(response => {
      if (response !== null) {
        this.sellingList = response
      }
      this.loading = false
    }).catch(_ => {
      this.loading = false
    })
  },
  methods: {
    createSellingByBuy(item) {
      this.$confirm('Do you want to buy now?', 'Hint', {
        confirmButtonText: 'Sure',
        cancelButtonText: 'Cancel',
        type: 'success'
      }).then(() => {
        this.loading = true
        createSellingByBuy({
          buyer: this.accountId,
          objectOfSale: item.objectOfSale,
          seller: item.seller
        }).then(response => {
          this.loading = false
          if (response !== null) {
            this.$message({
              type: 'success',
              message: 'Successful Purchase!!'
            })
          } else {
            this.$message({
              type: 'error',
              message: 'Failed purchase!'
            })
          }
          setTimeout(() => {
            window.location.reload()
          }, 1000)
        }).catch(_ => {
          this.loading = false
        })
      }).catch(() => {
        this.loading = false
        this.$message({
          type: 'info',
          message: 'Purchase Canceled'
        })
      })
    },
    updateSelling(item, type) {
      let tip = ''
      if (type === 'done') {
        tip = 'Confirmed Paid'
      } else {
        tip = 'Cancel Operation'
      }
      this.$confirm('Do you want ' + tip + '?', 'hint', {
        confirmButtonText: 'Sure',
        cancelButtonText: 'Cancel',
        type: 'success'
      }).then(() => {
        this.loading = true
        updateSelling({
          buyer: item.buyer,
          objectOfSale: item.objectOfSale,
          seller: item.seller,
          status: type
        }).then(response => {
          this.loading = false
          if (response !== null) {
            this.$message({
              type: 'success',
              message: tip + 'Successful operation!'
            })
          } else {
            this.$message({
              type: 'error',
              message: tip + 'Operation failed!'
            })
          }
          setTimeout(() => {
            window.location.reload()
          }, 1000)
        }).catch(_ => {
          this.loading = false
        })
      }).catch(() => {
        this.loading = false
        this.$message({
          type: 'info',
          message: 'Cancelled' + tip
        })
      })
    }
  }
}

</script>

<style>
  .container{
    width: 100%;
    text-align: center;
    min-height: 100%;
    overflow: hidden;
  }
  .tag {
    float: left;
  }

  .item {
    font-size: 14px;
    margin-bottom: 18px;
    color: #999;
  }

  .clearfix:before,
  .clearfix:after {
    display: table;
  }
  .clearfix:after {
    clear: both
  }

  .all-card {
    width: 280px;
    height: 380px;
    margin: 18px;
  }
</style>
