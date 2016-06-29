Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:58183 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbcF2TrP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 15:47:15 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: y2038@lists.linaro.org
Cc: Deepa Dinamani <deepa.kernel@gmail.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, shaggy@kernel.org,
        jfs-discussion@lists.sourceforge.net, trond.myklebust@primarydata.com,
        clm@fb.com, adilger.kernel@dilger.ca, tglx@linutronix.de,
        zyan@redhat.com, paul@paul-moore.com, sage@redhat.com,
        idryomov@gmail.com, linux-ext4@vger.kernel.org, cm224.lee@samsung.com,
        mfasheh@suse.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk,
        dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, elder@kernel.org, tytso@mit.edu,
        dedekind1@gmail.com, jbacik@fb.com, gregkh@linuxfoundation.org,
        adrian.hunter@intel.com, eparis@redhat.com,
        linux-f2fs-devel@lists.sourceforge.net, sfrench@samba.org,
        linux-audit@redhat.com, ocfs2-devel@oss.oracle.com, jack@suse.com,
        linux-mtd@lists.infradead.org, lustre-devel@lists.lustre.org,
        torvalds@linux-foundation.org, anna.schumaker@netapp.com,
        linux-btrfs@vger.kernel.org, jlbec@evilplan.org
Subject: Re: [Y2038] [PATCH v3 00/24] Delete CURRENT_TIME_SEC and replace current_fs_time()
Date: Wed, 29 Jun 2016 21:48:02 +0200
Message-ID: <4878160.cRxJJ9CCsj@wuerfel>
In-Reply-To: <1466890668-23400-1-git-send-email-deepa.kernel@gmail.com>
References: <1466890668-23400-1-git-send-email-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday, June 25, 2016 2:37:24 PM CEST Deepa Dinamani wrote:
> The series is aimed at getting rid of CURRENT_TIME, CURRENT_TIME_SEC macros
> and replacing current_fs_time() with current_time().
> The macros are not y2038 safe. There is no plan to transition them into being
> y2038 safe.
> ktime_get_* api's can be used in their place. And, these are y2038 safe.
> 
> CURRENT_TIME will be deleted after 4.8 rc1 as there is a dependency function
> time64_to_tm() for one of the CURRENT_TIME occurance.
> 
> Thanks to Arnd Bergmann for all the guidance and discussions.
> 
> Patches 3-5 were mostly generated using coccinelle.
> 
> All filesystem timestamps use current_fs_time() for right granularity as
> mentioned in the respective commit texts of patches. This has a changed
> signature, renamed to current_time() and moved to the fs/inode.c.
> 
> This series also serves as a preparatory series to transition vfs to 64 bit
> timestamps as outlined here: https://lkml.org/lkml/2016/2/12/104 .
> 
> As per Linus's suggestion in https://lkml.org/lkml/2016/5/24/663 , all the
> inode timestamp changes have been squashed into a single patch. Also,
> current_time() now is used as a single generic vfs filesystem timestamp api.
> It also takes struct inode* as argument instead of struct super_block*.
> Posting all patches together in a bigger series so that the big picture is
> clear.
> 
> As per the suggestion in https://lwn.net/Articles/672598/, CURRENT_TIME macro
> bug fixes are being handled in a series separate from transitioning vfs to use.
> 

Everything in this version looks good to me. Please add

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

and send a pull request to Al Viro, based on the latest linux-4.7-rc release.

	Arnd
