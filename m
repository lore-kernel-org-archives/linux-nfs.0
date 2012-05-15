Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42717 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966435Ab2EOTSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 15:18:12 -0400
Date: Tue, 15 May 2012 15:18:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Josef Bacik <josef@redhat.com>, Andreas Dilger <adilger@dilger.ca>,
        "Ted Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120515191810.GA11028@fieldses.org>
References: <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
 <20120514175822.GC1439@thunk.org>
 <20120514183316.GA1894@localhost.localdomain>
 <20120514185400.GA32026@fieldses.org>
 <20120514190500.GC1894@localhost.localdomain>
 <60F0B94D-FDB9-4401-B0EA-1A1C6DE4086F@dilger.ca>
 <20120515132857.GA1907@localhost.localdomain>
 <4FB2996F.40708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FB2996F.40708@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 07:59:11PM +0200, Marco Stornelli wrote:
> Only a really really stupid question (I don't know NFS protocol well
> enough). In 3.3 kernel, I see that only ext4 uses MS_I_VERSION, so I
> wonder: if i_version change it's needed for exportable fs and so for
> nfs, other exportable fs?

Yes, it's needed for others as well.  I believe btrfs and xfs are both
adding it.

We're currently using ctime for the nfs change attribute.  That's
effectively jiffy granularity.  So to see the problem at a minimum you'd
need two writes to be processed within one jiffy, and a stat to come
between them.  But that's a correctness problem, and we'd like to see it
fixed before it becomes more common.

More generally, it's useful to be able to ask whether a file changed
without rereading all its data, and a clock that registers every change
and is consistent across a filesystem sounds difficult to scale.  We may
eventually find we need something like this outside nfs.

--b.
