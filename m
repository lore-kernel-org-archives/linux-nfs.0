Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:44503 "EHLO mail.8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568Ab2I0PBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 11:01:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 2B4B112AFA1
	for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2012 16:52:19 +0200 (CEST)
Date: Thu, 27 Sep 2012 16:52:18 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120927145217.GA18962@8bytes.org>
References: <20120807134156.GP1996@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120807134156.GP1996@amd.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2012 at 03:41:56PM +0200, Joerg Roedel wrote:
> starting with Linux 3.6-rc1 I experience this BUG on one of my test
> machines. Please let me know if you need any additional information.
> 
> [   20.271810] ------------[ cut here ]------------
> [   20.276869] kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
> [   20.284306] invalid opcode: 0000 [#1] SMP
> [   20.288806] Modules linked in: nfs4 auth_rpcgss nfs fscache lockd sunrpc kvm_intel radeon kvm ttm drm_kms_helper i7core_edac drm edac_core joydev hpilo psmouse hid_generic i2c_algo_bit serio_raw usbhid hid bnx2

I still see this BUG with 3.6-rc7. Any fix in sight?


	Joerg


