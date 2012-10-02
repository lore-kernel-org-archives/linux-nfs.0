Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32885 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab2JBDdH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 23:33:07 -0400
Subject: Re: [nfs:testing 69/83] fs/nfs/nfs4state.c:127:9: error: 'nfs_callback_tcpport' undeclared
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121002021718.GB6691@localhost>
Date: Mon, 1 Oct 2012 20:32:57 -0700
Cc: kernel-janitors@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <F56D55B2-7999-4AA4-8A8F-495AAE9728B0@oracle.com>
References: <20121002021718.GB6691@localhost>
To: Fengguang Wu <fengguang.wu@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

That appears to be a merge error.  I believe it was fixed today in the "testing" branch.  If not, we'll get it addressed tomorrow.


On Oct 1, 2012, at 7:17 PM, Fengguang Wu wrote:

> Hi Chuck,
> 
> FYI, kernel build failed on
> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   2afdfa5a846246de50e1881f71ba5c0aac0b415f
> commit: 05f4c350ee02e9461c6ae3a880ea326a06835e37 [69/83] NFS: Discover NFSv4 server trunking when mounting
> config: x86_64-allyesconfig
> 
> All error/warnings:
> 
> fs/nfs/nfs4state.c: In function 'nfs40_discover_server_trunking':
> fs/nfs/nfs4state.c:127:9: error: 'nfs_callback_tcpport' undeclared (first use in this function)
> fs/nfs/nfs4state.c:127:9: note: each undeclared identifier is reported only once for each function it appears in
> fs/nfs/nfs4state.c:129:10: error: 'nfs_callback_tcpport6' undeclared (first use in this function)
> 
> vim +127 fs/nfs/nfs4state.c
> 
> 05f4c350 (Chuck Lever 2012-09-14  115)  */
> 05f4c350 (Chuck Lever 2012-09-14  116) int nfs40_discover_server_trunking(struct nfs_client *clp,
> 05f4c350 (Chuck Lever 2012-09-14  117) 				   struct nfs_client **result,
> 05f4c350 (Chuck Lever 2012-09-14  118) 				   struct rpc_cred *cred)
> 05f4c350 (Chuck Lever 2012-09-14  119) {
> 05f4c350 (Chuck Lever 2012-09-14  120) 	struct nfs4_setclientid_res clid = {
> 05f4c350 (Chuck Lever 2012-09-14  121) 		.clientid = clp->cl_clientid,
> 05f4c350 (Chuck Lever 2012-09-14  122) 		.confirm = clp->cl_confirm,
> 05f4c350 (Chuck Lever 2012-09-14  123) 	};
> 05f4c350 (Chuck Lever 2012-09-14  124) 	unsigned short port;
> 05f4c350 (Chuck Lever 2012-09-14  125) 	int status;
> 05f4c350 (Chuck Lever 2012-09-14  126) 
> 05f4c350 (Chuck Lever 2012-09-14 @127) 	port = nfs_callback_tcpport;
> 05f4c350 (Chuck Lever 2012-09-14  128) 	if (clp->cl_addr.ss_family == AF_INET6)
> 05f4c350 (Chuck Lever 2012-09-14  129) 		port = nfs_callback_tcpport6;
> 05f4c350 (Chuck Lever 2012-09-14  130) 
> 05f4c350 (Chuck Lever 2012-09-14  131) 	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
> 05f4c350 (Chuck Lever 2012-09-14  132) 	if (status != 0)
> 05f4c350 (Chuck Lever 2012-09-14  133) 		goto out;
> 
> ---
> 0-DAY kernel build testing backend         Open Source Technology Centre
> Fengguang Wu, Yuanhan Liu                              Intel Corporation
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



