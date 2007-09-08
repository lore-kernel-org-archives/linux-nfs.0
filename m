From: Greg KH <gregkh@suse.de>
Subject: Re: [2/4] 2.6.23-rc5: known regressions v2
Date: Sat, 8 Sep 2007 05:28:52 -0700
Message-ID: <20070908122852.GA30315@suse.de>
References: <46E27DEF.7060109@googlemail.com> <46E28351.8050900@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>,
	Ian Kent <raven@themaw.net>, autofs@linux.kernel.org,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	Dave Kleikamp <shaggy@austin.ibm.com>,
	jfs-discussion@lists.sourceforge.net,
	linux-usb-devel@lists.sourceforge.net,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oliver@neukum.org>,
	Tino Keitel <tino.keitel@gmx.de>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46E28351.8050900@googlemail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Sep 08, 2007 at 01:11:13PM +0200, Michal Piotrowski wrote:
> USB
> 
> Subject         : 2.6.23-rc1: USB hard disk broken
> References      : http://lkml.org/lkml/2007/7/25/62
> Last known good : ?
> Submitter       : Tino Keitel <tino.keitel@gmx.de>
> Caused-By       : ?
> Handled-By      : Oliver Neukum <oliver@neukum.org>
> Status          : unknown
> 
> Subject         : USB hard disk broken in 2.6.23-rc3 (autosuspend related)
> References      : http://bugzilla.kernel.org/show_bug.cgi?id=8892
> Last known good : ?
> Submitter       : Roman Jarosz <kedgedev@centrum.cz>
> Caused-By       : ?
> Handled-By      : Alan Stern <stern@rowland.harvard.edu>
> Workaround      : echo -1 >/sys/bus/usb/devices/1-4/power/autosuspend
> Status          : possible hardware problem

Oliver and Alan, is there any info about these?  Anything that I can
help out with?

thanks,

greg k-h
