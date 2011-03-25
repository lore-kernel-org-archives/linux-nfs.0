From: Dros Adamson <dros@netapp.com>
Subject: Re: [PATCH] Cleanup XDR parsing for LAYOUTGET, GETDEVICEINFO
Date: Fri, 25 Mar 2011 10:01:35 -0400
Message-ID: <3FB1B364-AA14-4DBB-B47B-1A9193A979C0@netapp.com>
References: <1300999701-2244-1-git-send-email-dros@netapp.com> <1301002148.27109.5.camel@lade.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab1CYOBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 10:01:36 -0400
In-Reply-To: <1301002148.27109.5.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.

-dros
sd
On Mar 24, 2011, at 5:29 PM, Trond Myklebust wrote:

> On Thu, 2011-03-24 at 16:48 -0400, Weston Andros Adamson wrote:
> 
>> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
>> index 433204f..414c7e9 100644
>> --- a/fs/nfs/nfs4filelayoutdev.c
>> +++ b/fs/nfs/nfs4filelayoutdev.c
>> @@ -261,7 +261,7 @@ out:
>>  * Currently only support ipv4, and one multi-path address.
>>  */
>> static struct nfs4_pnfs_ds *
>> -decode_and_add_ds(__be32 **pp, struct inode *inode)
>> +decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode)
>> {
>> 	struct nfs4_pnfs_ds *ds = NULL;
>> 	char *buf;
>> @@ -269,25 +269,34 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>> 	u32 ip_addr, port;
>> 	int nlen, rlen, i;
>> 	int tmp[2];
>> -	__be32 *r_netid, *r_addr, *p = *pp;
>> +	__be32 *p;
>> 
>> 	/* r_netid */
>> +	p = xdr_inline_decode(streamp, 4);
>> +	if (unlikely(!p))
>> +		goto out_err;
>> 	nlen = be32_to_cpup(p++);
>> -	r_netid = p;
>> -	p += XDR_QUADLEN(nlen);
>> 
>> -	/* r_addr */
>> -	rlen = be32_to_cpup(p++);
>> -	r_addr = p;
>> -	p += XDR_QUADLEN(rlen);
>> -	*pp = p;
>> +	p = xdr_inline_decode(streamp, nlen);
>> +	if (unlikely(!p))
>> +		goto out_err;
>> 
>> 	/* Check that netid is "tcp" */
>> -	if (nlen != 3 ||  memcmp((char *)r_netid, "tcp", 3)) {
>> +	if (nlen != 3 ||  memcmp((char *)p, "tcp", 3)) {
>> 		dprintk("%s: ERROR: non ipv4 TCP r_netid\n", __func__);
>> 		goto out_err;
>> 	}
>> 
>> +	/* r_addr */
>> +	p = xdr_inline_decode(streamp, 4);
>> +	if (unlikely(!p))
>> +		goto out_err;
>> +	rlen = be32_to_cpup(p);
>> +
>> +	p = xdr_inline_decode(streamp, rlen);
>> +	if (unlikely(!p))
>> +		goto out_err;
>> +
>> 	/* ipv6 length plus port is legal */
>> 	if (rlen > INET6_ADDRSTRLEN + 8) {
>> 		dprintk("%s: Invalid address, length %d\n", __func__,
>> @@ -295,8 +304,10 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>> 		goto out_err;
>> 	}
>> 	buf = kmalloc(rlen + 1, GFP_KERNEL);
>> +	if (unlikely(!buf))
>> +		goto out_err;
>> 	buf[rlen] = '\0';
>> -	memcpy(buf, r_addr, rlen);
>> +	memcpy(buf, p, rlen);
>> 
>> 	/* replace the port dots with dashes for the in4_pton() delimiter*/
>> 	for (i = 0; i < 2; i++) {
> 
> I had a small conflict with this last hunk due to an existing patch in
> the nfs-for-2.6.39 branch, but I think I've fixed it up correctly.
> 
> Please check the nfs-for-2.6.39 branch on
>     git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

