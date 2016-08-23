Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:59472 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754258AbcHWPCc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 11:02:32 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Deepa Dinamani <deepa.kernel@gmail.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, tglx@linutronix.de,
        torvalds@linux-foundation.org, tytso@mit.edu, viro@zeniv.linux.org.uk,
        y2038@lists.linaro.org, adilger.kernel@dilger.ca,
        adrian.hunter@intel.com, anna.schumaker@netapp.com, buchino@cisco.com,
        ceph-devel@vger.kernel.org, clm@fb.com, cm224.lee@samsung.com,
        dedekind1@gmail.com, dsterba@suse.com, dushistov@mail.ru,
        elder@kernel.org, eparis@redhat.com, hiralpat@cisco.com,
        idryomov@gmail.com, jack@suse.com, jaegeuk@kernel.org, jbacik@fb.com,
        jejb@linux.vnet.ibm.com, jfs-discussion@lists.sourceforge.net,
        jlbec@evilplan.org, john.stultz@linaro.org, linux-audit@redhat.com,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        lustre-devel@lists.lustre.org, martin.petersen@oracle.com,
        mfasheh@suse.com, ocfs2-devel@oss.oracle.com, paul@paul-moore.com,
        sage@redhat.com, sfrench@samba.org, shaggy@kernel.org,
        sramars@cisco.com, trond.myklebust@primarydata.com, zyan@redhat.com
Subject: Re: [GIT PULL] [PATCH v4 00/26] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
Date: Tue, 23 Aug 2016 16:51:39 +0200
Message-ID: <2295046.g7jOF3qsLW@wuerfel>
In-Reply-To: <20160815162312.GA19794@kroah.com>
References: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com> <20160815162312.GA19794@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday, August 15, 2016 6:23:12 PM CEST Greg KH wrote:
> On Sat, Aug 13, 2016 at 03:48:12PM -0700, Deepa Dinamani wrote:
> > The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.
> > The macros are not y2038 safe. There is no plan to transition them into being
> > y2038 safe.
> > ktime_get_* api's can be used in their place. And, these are y2038 safe.
> 
> Who are you execting to pull this huge patch series?

Dave Chinner suggested to have Al Viro pick up the whole series.

> Why not just introduce the new api call, wait for that to be merged, and
> then push the individual patches through the different subsystems?
> After half of those get ignored, then provide a single set of patches
> that can go through Andrew or my trees.

That was the original approach for v4.7, but (along with requesting
a number of reworks that Deepa incorporated), Linus preferred doing
the API change done in one chunk, see
https://patchwork.kernel.org/patch/9134249/

	Arnd
