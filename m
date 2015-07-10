Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28364 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbbGJOd0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 10:33:26 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 03/12] xprtrdma: Increase default credit limit
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBiMDM5VP5ev3LFfapX-5amqukH=dJdaEZVcZc9SSP2CCg@mail.gmail.com>
Date: Fri, 10 Jul 2015 10:33:22 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B6E6A65D-DE61-4A95-91D7-1E8A5132F7EE@oracle.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net> <20150709204208.26247.52073.stgit@manet.1015granger.net> <CANjDDBiMDM5VP5ev3LFfapX-5amqukH=dJdaEZVcZc9SSP2CCg@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2015, at 6:45 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:

> Increasing the default slot table entries will increase the MR
> requirements per mount.

Yes, but:

> Currently, with 32 as default Client ends up allocating 2178 frmrs
> (ref: kernel 4.1-rc4) for a single mount. With 128 frmr requirement
> for startup would be 8448.

Commit 40c6ed0c8a7f ("xprtrdma: Reduce per-transport MR allocation”)
is supposed to address this. This commit is in 4.1.

The number of MRs per credit is now 256 divided by the HCA’s
max_fast_reg_page_list_len. See frwr_op_open().

For mlx4 the number of MRs per credit is just 1, for example.


> 8K+ MRs per mount just for start-up, I am a little doubtful about this
> change. We can always release-note that "for better performance
> increase the slot table entries by echo 128 >
> /proc/sys/sunrpc/rdma_slot_table_entries"
> 
> -Regards
> Devesh
> 
> On Fri, Jul 10, 2015 at 2:12 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> In preparation for similar increases on NFS/RDMA servers, bump the
>> advertised credit limit for RPC/RDMA to 128. This allocates some
>> extra resources, but the client will continue to allow only the
>> number of RPCs in flight that the server requests via its advertised
>> credit limit.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xprtrdma.h |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
>> index b176130..b7b279b 100644
>> --- a/include/linux/sunrpc/xprtrdma.h
>> +++ b/include/linux/sunrpc/xprtrdma.h
>> @@ -49,7 +49,7 @@
>>  * a single chunk type per message is supported currently.
>>  */
>> #define RPCRDMA_MIN_SLOT_TABLE (2U)
>> -#define RPCRDMA_DEF_SLOT_TABLE (32U)
>> +#define RPCRDMA_DEF_SLOT_TABLE (128U)
>> #define RPCRDMA_MAX_SLOT_TABLE (256U)
>> 
>> #define RPCRDMA_DEF_INLINE  (1024)     /* default inline max */
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



