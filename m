From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: Union mounts, NFS, and locking
Date: Thu, 16 Jul 2009 13:25:13 -0400
Message-ID: <20090716172512.GM27582@shell>
References: <20090714201940.GF27582@shell> <200907142036.n6EKaexe017464@agora.fsl.cs.sunysb.edu> <20090714220515.GH27582@shell> <20090715172758.GA13893@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932844AbZGPR0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 13:26:06 -0400
In-Reply-To: <20090715172758.GA13893@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 15, 2009 at 01:27:59PM -0400, J. Bruce Fields wrote:
> On Tue, Jul 14, 2009 at 06:05:16PM -0400, Valerie Aurora wrote:
> > On Tue, Jul 14, 2009 at 04:36:40PM -0400, Erez Zadok wrote:
> > > In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
> > >
> > > > Okay, so my best idea for a solution is to introduce a new NFS mount
> > > > option that means the server promises that the exported file system is
> > > > read-only (using superblock read-only count scheme locally).  E.g.:
> 
> Language nitpick: the term "read-only" is confusing.  Files
> (/proc/mounts) and filesystems (nfs) that are "read-only" can still
> change.
> 
> I'd be happier with "unchanging" or "constant" or "static".

What about "immutable"?  It should be familiar from inode attributes.

> The mount options aren't really in the protocol--so it'd probably take
> the form of a filesystem-granularity attribute that the client could
> query (and then fail the mount if the client didn't like the answer).
> 
> But even then: the fact is that someone will want to update the
> filesystem some day.  And there's no way to force every client
> administrator to remount.  So we'd have to decide how to handle that
> case.

Agreed.  I'm no NFS expert, but I think that treating it as if the NFS
server had stopped responding might be a start?

-VAL
