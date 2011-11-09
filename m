Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50359 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395Ab1KIR3X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 12:29:23 -0500
Message-ID: <4EBAB863.1030303@panasas.com>
Date: Wed, 9 Nov 2011 09:29:07 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <tigran.mkrtchyan@desy.de>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: failed to compile kernel due to object layout
References: <CAGue13qr5iq=yhCA5BEzeoX94-ha7y4-fXMxH6C1g0nUia2Ceg@mail.gmail.com>
In-Reply-To: <CAGue13qr5iq=yhCA5BEzeoX94-ha7y4-fXMxH6C1g0nUia2Ceg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/09/2011 02:48 AM, Tigran Mkrtchyan wrote:
> Hi Boaz,
> 
> did I miss configured something?
> 
> Kernel: arch/x86/boot/bzImage is ready  (#59)
> ERROR: "ore_read" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> ERROR: "ore_put_io_state" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> ERROR: "ore_write" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> ERROR: "ore_check_io" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> ERROR: "ore_verify_layout" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> ERROR: "ore_get_rw_state" [fs/nfs/objlayout/objlayoutdriver.ko] undefined!
> WARNING: modpost: Found 3 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> tigran@anahit:~/nfs-2.6>
> 
> 
> config file attached.
> 
> Tigran.

Which tree is this?
Because in Benny's tree there was such a problem. But in Linus 3.2-rc1 it 
should be already fixed.

In some version of Benny's tree it is terminally broken. (No why out)
You'll need a patch. Tell me which tree and I'll make one for you

Sorry
Boaz
