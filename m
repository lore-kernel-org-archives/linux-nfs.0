From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Wed, 22 Jul 2009 17:47:16 -0400
Message-ID: <1248299236.9202.3.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
	 <1248196339.21343.8.camel@heimdal.trondhjem.org>
	 <4A65FCB2.6080903@candelatech.com>
	 <1248199140.21343.17.camel@heimdal.trondhjem.org>
	 <4A660295.9020807@candelatech.com>
	 <1248200897.21343.19.camel@heimdal.trondhjem.org>
	 <4A6609A9.3000504@candelatech.com>
	 <1248211050.21343.38.camel@heimdal.trondhjem.org>
	 <A7103385-4525-4B7B-9CBA-5DBCB99A98F0@netapp.com>
	 <1248294013.5234.35.camel@heimdal.trondhjem.org>
	 <74713B5B-DF7F-4357-AE3A-0F6B44C41116@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Greear <greearb@candelatech.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60662 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663AbZGVVrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 17:47:22 -0400
In-Reply-To: <74713B5B-DF7F-4357-AE3A-0F6B44C41116@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-07-22 at 17:32 -0400, Andy Adamson wrote:
> nfs4_init_session should simply return if the nfs_client cl_cons_state  
> is not NFS_CS_SESSION_INITING.
> I shouldn't be trying to set the session max_resp_sz/max_rqst_sz to  
> the rsize/wsize, but rather to the maximum rsize/wsize supported by  
> the client.
> If the server accepts or increases the max_resp_sz/max_rqst_sz then  
> all is well.
> If the server reduces the max_resp_sz/max_rqst_sz, the maximum rsize/ 
> wsize available for NFSv4.1 partition mounts to the server needs to be  
> reduced accordingly. So the nfs_server rsize/wsize needs to be bound  
> by the session max_resp_sz/max_rqst_sz as well as by the maximum  
> supported size.

Well.... The rsize/wsize is one thing, but how about acls? We simply
don't know how big they may become.

An alternative would be to let the server choose the
max_rqst_sz/max_resp_sz by always requesting the maximum allowed value.

Trond

