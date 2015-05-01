Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51726 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbbEAC3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 22:29:42 -0400
Date: Fri, 1 May 2015 03:29:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150501022939.GQ889@ZenIV.linux.org.uk>
References: <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150501020324.GP889@ZenIV.linux.org.uk>
 <20150501122333.1476c999@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150501122333.1476c999@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > What kind of consistency warranties do callers expect, BTW?  You do realize
> > that between iterate_dir() and callbacks an entry might have been removed
> > and/or replaced?
> 
> For READDIR_PLUS, lookup_one_len is called on each name and it requires
> i_mutex, so the code currently holds i_mutex over the whole sequence.
> This is triggering a deadlock.

Yes, I've seen the context.  However, you are _not_ holding it between
actual iterate_dir() and those callbacks, which opens a window when
directory might have been changed.

Again, what kind of consistency is expected by callers?  Are they ready to
cope with "there's no such entry anymore" or "inumber is nothing like
what we'd put in ->ino, since it's no the same object" or "->d_type is
completely unrelated to what we'd found, since the damn thing had been
removed and created from scratch"?
