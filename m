Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:56061 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332Ab2FGQBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 12:01:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 3ECB112AFE9
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jun 2012 18:01:10 +0200 (CEST)
Date: Thu, 7 Jun 2012 18:01:09 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect
 mount option
Message-ID: <20120607160109.GS12795@8bytes.org>
References: <20120607150456.GO12795@8bytes.org>
 <4FD0C4C2.8020605@netapp.com>
 <20120607155006.GR12795@8bytes.org>
 <4FD0CEB0.9040804@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD0CEB0.9040804@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 07, 2012 at 11:54:24AM -0400, Bryan Schumaker wrote:
> On 06/07/2012 11:50 AM, Joerg Roedel wrote:
> > On Thu, Jun 07, 2012 at 11:12:02AM -0400, Bryan Schumaker wrote:
> > 
> >> Can you use `mount -v` to get more output?
> > 
> > Btw, it also works when I manually set the nfs-version at mount:
> > 
> > mount -o nfsvers=3 ...
> 
> What about `mount -o vers=4 ...`?  I'm compiling a kernel right now to
> see if I can reproduce this, what NFS .config options do you have set?
> (`cat .config | grep CONFIG_NFS_` should be good enough).

mount -o vers=2 and -o vers=3 works
mount -o vers=4 fails with:

root@chrom:~# mount -o vers=4 lemmy:/data/repos/ /data/lemmy/
mount.nfs: mounting lemmy:/data/repos/ failed, reason given by server:
  No such file or directory

# grep CONFIG_NFS_ .config
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y


	Joerg


