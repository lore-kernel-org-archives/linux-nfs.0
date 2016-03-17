Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26239 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbcCQOB6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 10:01:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH v2] svcrdma: add IPv6 support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160317084210.GE25216@leon.nu>
Date: Thu, 17 Mar 2016 10:01:50 -0400
Cc: Shirley Ma <shirley.ma@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Message-Id: <9D93B217-3044-4404-8EB4-6CD0DD759642@oracle.com>
References: <56E9A8DD.8030308@oracle.com> <20160317084210.GE25216@leon.nu>
To: leon@leon.nu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Server-side patch; cc-ing Bruce.

> On Mar 17, 2016, at 4:42 AM, Leon Romanovsky <leon@leon.nu> wrote:
> 
> On Wed, Mar 16, 2016 at 11:41:33AM -0700, Shirley Ma wrote:
>> Add rdma6 option to support NFS/RDMA IPv6.
>> Allow both IPv4 and IPv6 to bind same port at the same time,
>> restricts use of the IPv6 socket to IPv6 communication.
>> 
>> Changes from v1:
>> - Check rdma_set_afonly return value (suggested by Leon Romanovsky)
> 
> Looks good to me.
> Acked-by: Leon Romanovsky <leonro@mellanox.com>
> 
> Thanks.
> 
>> 
>> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
>> ---
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -869,7 +869,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>> 	int ret;
>> 
>> 	dprintk("svcrdma: Creating RDMA socket\n");
>> -	if (sa->sa_family != AF_INET) {
>> +	if ((sa->sa_family != AF_INET) && (sa->sa_family != AF_INET6)) {
> 
>> 		dprintk("svcrdma: Address family %d is not supported.\n", sa->sa_family);
>> 		return ERR_PTR(-EAFNOSUPPORT);
>> 	}
>> @@ -885,6 +885,16 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>> 		goto err0;
>> 	}
>> 
>> +	/* Allow both IPv4 and IPv6 sockets to bind a single port
>> +	 * at the same time.
>> +	 */
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +	ret = rdma_set_afonly(listen_id, 1);
>> +	if (ret) {
>> +		dprintk("svcrdma: rdma_set_afonly failed = %d\n", ret);
>> +		goto err1;
>> +	}
>> +#endif
>> 	ret = rdma_bind_addr(listen_id, sa);
>> 	if (ret) {
>> 		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



