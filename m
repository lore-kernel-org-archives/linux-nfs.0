Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:34977 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbcHPSxL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2016 14:53:11 -0400
Date: Tue, 16 Aug 2016 20:53:20 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        y2038 Mailman List <y2038@lists.linaro.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Brian Uchino <buchino@cisco.com>,
        ceph-devel <ceph-devel@vger.kernel.org>, Chris Mason <clm@fb.com>,
        Changman Lee <cm224.lee@samsung.com>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        David Sterba <dsterba@suse.com>, Evgeniy Dushistov <dushistov@mail.ru>,
        Alex Elder <elder@kernel.org>, Eric Paris <eparis@redhat.com>,
        Hiral Patel <hiralpat@cisco.com>, Ilya Dryomov <idryomov@gmail.com>,
        Jan Kara <jack@suse.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
        Josef Bacik <jbacik@fb.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        jfs-discussion@lists.sourceforge.net, Joel Becker <jlbec@evilplan.org>,
        John Stultz <john.stultz@linaro.org>, linux-audit@redhat.com,
        linux-btrfs <linux-btrfs@vger.kernel.org>, linux-ext4@vger.kernel.org,
        "Linux F2FS DEV, Mailing List"
	<linux-f2fs-devel@lists.sourceforge.net>,
        linux-mtd <linux-mtd@lists.infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        lustre-devel@lists.lustre.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com,
        Paul Moore <paul@paul-moore.com>, Sage Weil <sage@redhat.com>,
        Steve French <sfrench@samba.org>, Dave Kleikamp <shaggy@kernel.org>,
        Suma Ramars <sramars@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "Yan, Zheng" <zyan@redhat.com>
Subject: Re: [GIT PULL] [PATCH v4 00/26] Delete CURRENT_TIME and
 CURRENT_TIME_SEC macros
Message-ID: <20160816185320.GB6513@kroah.com>
References: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
 <20160815162312.GA19794@kroah.com>
 <CABeXuvp027DZR0=zQPp86oGdi2B+Gh16z8_FyoY5UDUdHXAngA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CABeXuvp027DZR0=zQPp86oGdi2B+Gh16z8_FyoY5UDUdHXAngA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 16, 2016 at 11:18:52AM -0700, Deepa Dinamani wrote:
> Thank you for the suggestion.
> 
> > Who are you execting to pull this huge patch series?
> 
> The last pull request was addressed to Al as per Arnd's suggestion.
> I'm not completely sure who should it be addressed to.
> 
> > Why not just introduce the new api call, wait for that to be merged, and
> > then push the individual patches through the different subsystems?
> > After half of those get ignored, then provide a single set of patches
> > that can go through Andrew or my trees.
> 
> Arnd and I tried to do this a few ways.
> 
> We can try to introduce the api first like you suggest.
> 
> There are a few Acks already on the patches.
> And, patches 2-5 also need to be merged through some common tree like
> yours or Andrew's as you suggest.
> 
> So, if everyone is ok, I could do the following:
> 
> 1. Post patches 1-5 for rc-2.

-rc2 is already released, and we aren't adding new apis this late in the
release cycle, sorry.

> 2. Post all other patches to respective maintainers after rc-2
> 3. Then after patches get ignored or merged, post remaining as a
> series for you or Andrew to pick up.

The apis need to be aimed for 4.9-rc1, it's too late for 4.8, sorry.

greg k-h
