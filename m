From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] mmap corruption
Date: Mon, 7 Apr 2003 16:56:15 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16017.37263.648356.201846@charged.uio.no>
References: <3E8DDB13.9020009@RedHat.com>
	<shsistt7wip.fsf@charged.uio.no>
	<20030405164741.GA6450@RedHat.com>
	<16016.7633.982870.860147@charged.uio.no>
	<20030407140052.GA1471@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: SteveD@RedHat.com
In-Reply-To: <20030407140052.GA1471@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > OK, I understand your point.  And Yes, ndirty and ncommit
     > always seem to be zero when nfs_wb_all() returns. Only when
     > npages != 0 is when I get the corruption.

     > I didn't realize that npages != 0 meant there are only pending
     > reads *not* pending writes... Thanks for that clarification....

My mistake. npages counts only writes...

However, I still stand by my statement that nfs_wb_all() is supposed
to ensure that *all* pending writes have been cleared.
The only explanation for npages != 0 is if

  a) an error occurred with nfs_wb_all() (we should perhaps test the
     return value of nfs_wb_all() there). Under normal circumstances,
     an error should only occur if you're using soft mounts, though.

  b) somebody redirtied the page *after* nfs_wb_all() was done.

Cheers,
  Trond
