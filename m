Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43158 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753583Ab0GGW5W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 18:57:22 -0400
From: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
To: "andros@netapp.com" <andros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 7 Jul 2010 15:57:20 -0700
Subject: RE: [PATCH 0/16] pnfs-submit fix layout allocation and reference
 counting
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9213D4EC6E57@orsmsx504.amr.corp.intel.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
In-Reply-To: <1278542063-4009-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



>-----Original Message-----
>From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>owner@vger.kernel.org] On Behalf Of andros@netapp.com
>Sent: Wednesday, July 07, 2010 3:34 PM
>To: bhalevy@panasas.com
>Cc: linux-nfs@vger.kernel.org
>Subject: [PATCH 0/16] pnfs-submit fix layout allocation and reference
>counting
>
>
>
>The current nfs_inode has an embedded pnfs_layout_type structure, with per
>layout type private data allocated. Change nfs_inode->layout to be a
>pointer
>to a pnfs_layout_type structure, embed the pnfs_layout_type in the per
>layout type structure, and allocate both.
>
>The current pnfs_layout_type allocation waits on a bit lock to handle
>concurrent allocation attempts. Replace this with the normal form.
>
>The current pnfs_layout_type reference counting is very un-clear, and one
>instance of put_layout was called outside the i_lock which probably was
>causing the intermittant pnfs_layout_type refcount bug we've been seeing.
>
>Replace the nfs_inode->layout reference counting with the following scheme:

I am a newbee and would appreciate a little enlightenment:

I read an article from a few years ago that stated 'The "kobject" structure first made its appearance in the 2.5.45 development kernel.  It was initially meant as a simple way of unifying kernel code which manages reference counted objects.'

It seems from my naïve viewpoint that a "kobject" might be used here.  Why not?  Does it have something to do with the "mission creep" mentioned in the article?

Thanks for your patients. 

-=# Paul Gilliam #=-


