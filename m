Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43713 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbbD2TTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 15:19:36 -0400
Date: Wed, 29 Apr 2015 15:19:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150429191934.GA23980@fieldses.org>
References: <553663B7.7030506@gmail.com>
 <20150421215417.GE13782@fieldses.org>
 <553781E2.1000900@gmail.com>
 <20150422150703.GA1247@fieldses.org>
 <20150423094431.1a8aa68b@notabene.brown>
 <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150429125728.69ddfc6c@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 12:57:28PM +1000, NeilBrown wrote:
> In any case, holding a mutex while waiting for an upcall is probably a bad
> idea.  We should try to find a way to work around that...

Yeah, it sounds fragile even if we could fix this particular issue in
mountd.

> Any ideas Bruce ?-)

Looking at nfsd_buffered_readdir():

	/*
	 * Various filldir functions may end up calling back into
	 * lookup_one_len() and the file system's ->lookup() method.
	 * These expect i_mutex to be held, as it would within readdir.
	 */
        host_err = mutex_lock_killable(&dir_inode->i_mutex);

and as far as I can tell Kinglong's approach (adding an unlock and lock
around nfsd_cross_mnt() calls might actually be OK.

Though in general I expect

	lock()
	...code...
	unlock()

to mark a critical section and would be unpleasantly surprised to
discover that a function somewhere in the middle had a buried
unlock/lock pair.

Maybe drop the locking from nfsd_buffered_readdir and *just* take the
i_mutex around lookup_one_len(), if that's the only place we need it?

--b.
