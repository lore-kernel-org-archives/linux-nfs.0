Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30473 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab2D3TKs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 15:10:48 -0400
Message-ID: <4F9EE3B5.4060502@netapp.com>
Date: Mon, 30 Apr 2012 15:10:45 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] NFS: Rename nfs4_proc_get_root()
References: <1335811229-2989-1-git-send-email-bjschuma@netapp.com> <1335811229-2989-2-git-send-email-bjschuma@netapp.com> <20120430190743.GA2461@umich.edu>
In-Reply-To: <20120430190743.GA2461@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2012 03:07 PM, Jim Rees wrote:

> bjschuma@netapp.com wrote:
> 
>   From: Bryan Schumaker <bjschuma@netapp.com>
>   
>   This function is really getting the root filehandle and not the root
>   dentry of the filesystem.  I also removed the rpc_ops lookup from
>   nfs4_get_rootfh() under the assumption that if we reach this function
>   then we already know we are using NFS v4.
> 
> And when NFSv5 comes out?


Well, this function is called "nfs4_get_rootfh()".  nfs5_get_rootfh() will probably be something different and also not need an rpc op...

- Bryan
