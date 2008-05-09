From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: referrals
Date: Fri, 9 May 2008 12:52:04 -0400
Message-ID: <20080509165204.GB1907@fieldses.org>
References: <20080509011918.GK12690@fieldses.org> <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756124AbYEIQwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2008 12:52:12 -0400
In-Reply-To: <20080509152750.GA325@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2008 at 11:27:50AM -0400, bfields wrote:
> On Thu, May 08, 2008 at 10:10:39PM -0700, Trond Myklebust wrote:
> > On Thu, 2008-05-08 at 21:19 -0400, J. Bruce Fields wrote:
> > > An attempt to follow an nfsv4 referral is leading to a hang.  I'm doing
> > > an "ls" on the absent directory.  A network trace shows the server
> > > returning with a sane-looking response to the getattr of fs_locations.
> > > I've appended the part of the sysrq-t trace for "ls".  Any ideas?
> > > 
> > > --b.
> > 
> > What kernel?
> 
> It was a few unrelated nfsd and gss patches on top of
> e31a94ed371c70855eb30b77c490d6d85dd4da26, which is between 2.6.25 and
> 2.6.26-rc1 (but I think has all the nfs stuff that went into -rc1).
> Happy to retest with something different.

Ah-hah.  The server was returning two fslocations records, both for the
same server--one with the target server's ip address, one with a
hostname for it.  Once the server was modified to return only one record
(with the ip address), everything worked.

Of course it's a known limitation that the client only handles ip
addresses, but a look at the code in
fs/nfs/nfs4namespace.c:nfs_follow_referral() shows that it *tries* to
skip over any non-ip addresses, so the presence of such shouldn't have
changed behavior.

So there must be something wrong with that code in the !valid_ipaddr4()
case?

--b.
