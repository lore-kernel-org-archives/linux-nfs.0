From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [2/4] 2.6.23-rc6: known regressions
Date: Fri, 14 Sep 2007 13:21:25 -0400
Message-ID: <20070914172124.GA2419@fieldses.org>
References: <46E8187E.9000006@googlemail.com> <46E81ACE.6030305@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	Dave Kleikamp <shaggy@austin.ibm.com>,
	jfs-discussion@lists.sourceforge.net,
	Andy Whitcroft <apw@shadowen.org>, sct@redhat.com,
	adilger@clusterfs.com, linux-ext4@vger.kernel.org,
	linux-acpi@vger.kernel.org, Len Brown <lenb@kernel.org>,
	Chuck Ebbert <cebbert@redhat.com>, dth <dth@dth.net>,
	Neil Brown <neilb@suse.de>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755690AbXINRWB@vger.kernel.org>
In-Reply-To: <46E81ACE.6030305@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Sep 12, 2007 at 06:58:54PM +0200, Michal Piotrowski wrote:
> Subject         : [NFSv4] 2.6.23-rc4 oops in nfs4_cb_recall
> References      : http://lkml.org/lkml/2007/9/4/53
>                   http://bugzilla.kernel.org/show_bug.cgi?id=9003
> Last known good : ?
> Submitter       : Daniel J Blueman <daniel.blueman@gmail.com>
> Caused-By       : ?
> Handled-By      : ?
> Workaround      : http://bugzilla.kernel.org/attachment.cgi?id=12797
> Status          : unknown

I have patches which fix this, which we're testing.  (See bugzilla.)
It's a long-standing bug, not a regression.

> Subject         : [NFSD OOPS] 2.6.23-rc1-git10
> References      : http://lkml.org/lkml/2007/8/2/462
> Last known good : ?
> Submitter       : Andrew Clayton <andrew@digital-domain.net>
> Caused-By       : ?
> Handled-By      : ?
> Status          : unknown

Neil's working on this.  Also not a regression.

--b.
