Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15436 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab2JGWGP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Oct 2012 18:06:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH-Resend] NFS41: layoutget optimize and pnfsblock cleanup
Date: Sun, 7 Oct 2012 22:06:12 +0000
Message-ID: <mrjgxqrrinodrdsaqxus6fyb.1349647566180@email.android.com>
References: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
In-Reply-To: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aren't these already in the nfs-for-next branch?

Peng Tao <bergwolf@gmail.com> wrote:


Hi Trond,

Following first three patches were sent before and optimize layoutget size.
Last patch is cleanup and is also sent before.

Sorry that I have to send patches as attachments. I am having problem
with my smtp setup.

Thanks,
Tao

Peng Tao (4):
  NFS: track direct IO left bytes
  NFS41: send real write size in layoutget
  NFS41: send real read size in layoutget
  pnfsblock: cleanup nfs4_blkdev_get

 fs/nfs/blocklayout/blocklayout.c    |   38 ++++++++++++++++++++++++++++++++--
 fs/nfs/blocklayout/blocklayout.h    |    1 -
 fs/nfs/blocklayout/blocklayoutdev.c |   25 ++++------------------
 fs/nfs/direct.c                     |   12 +++++++++++
 fs/nfs/internal.h                   |    1 +
 fs/nfs/objlayout/objio_osd.c        |    9 +++++++-
 fs/nfs/pnfs.c                       |   16 ++++++++++++--
 fs/nfs/pnfs.h                       |    3 +-
 8 files changed, 76 insertions(+), 29 deletions(-)
