Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42161 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467Ab2I0PcG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 11:32:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: RE: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Date: Thu, 27 Sep 2012 15:32:02 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120807134156.GP1996@amd.com>
 <20120927145217.GA18962@8bytes.org>
In-Reply-To: <20120927145217.GA18962@8bytes.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Joerg Roedel [mailto:joro@8bytes.org]
> Sent: Thursday, September 27, 2012 10:52 AM
> To: Myklebust, Trond
> Cc: Joerg Roedel; linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org;
> torvalds@linux-foundation.org
> Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
> 
> On Tue, Aug 07, 2012 at 03:41:56PM +0200, Joerg Roedel wrote:
> > starting with Linux 3.6-rc1 I experience this BUG on one of my test
> > machines. Please let me know if you need any additional information.
> >
> > [   20.271810] ------------[ cut here ]------------
> > [   20.276869] kernel BUG at
> /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
> > [   20.284306] invalid opcode: 0000 [#1] SMP
> > [   20.288806] Modules linked in: nfs4 auth_rpcgss nfs fscache lockd sunrpc
> kvm_intel radeon kvm ttm drm_kms_helper i7core_edac drm edac_core
> joydev hpilo psmouse hid_generic i2c_algo_bit serio_raw usbhid hid bnx2
> 
> I still see this BUG with 3.6-rc7. Any fix in sight?

Does your checked out copy of 3.6-rc7 contain commit c50669 (NFS: Clear key construction data if the idmap upcall fails)? The latter was merged in3.6-rc3, and is reported to fix the problem for the other testers.

Trond
