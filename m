Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:43045 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab1GYVfl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2011 17:35:41 -0400
Date: Mon, 25 Jul 2011 17:35:38 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: tao.peng@emc.com, linux-nfs@vger.kernel.org, bhalevy@tonian.com,
        bergwolf@gmail.com
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
Message-ID: <20110725213538.GB7717@merit.edu>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
 <4E18614C.4010002@tonian.com>
 <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com>
 <1311621204.28209.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311621204.28209.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  On Wed, 2011-07-20 at 01:52 -0400, tao.peng@emc.com wrote: 
  > Hi, Trond,
  > 
  > Any comments on this patch? I still get kernel crash when pnfs write is attempted but fails and calls pnfs_ld_write_done(). It seems object layout uses the same code path as well. But I don't find the patch in either your tree or Benny's tree. Are there any concerns?
  > 
  > Thanks,
  > Tao
  
  The whole pnfs_ld_write_done thing is bogus and needs to be replaced
  with something sane. It is trying to initiate a WRITE RPC call with the
  wrong block size, and is calling the MDS rpc_call_done() and
  rpc_release() with an uninitialised rpc task pointer.
  
  Ditto for pnfs_ld_read_done.

Benny / Boaz, have you run into this problem with object layout?
