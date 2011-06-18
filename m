Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41425 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610Ab1FRTuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jun 2011 15:50:02 -0400
Date: Sat, 18 Jun 2011 15:50:00 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs-utils crossmnt bugfix, and cleanup
Message-ID: <20110618195000.GA28536@fieldses.org>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
 <4DFCA7C2.8050604@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DFCA7C2.8050604@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jun 18, 2011 at 09:27:30AM -0400, Steve Dickson wrote:
> Hey Bruce,
> 
> On 06/14/2011 10:58 AM, J. Bruce Fields wrote:
> > We've long had a bug with crossmnt handling which could cause a parent's
> > export options to override those of a child in some cases.
> > 
> > While I was there, I also did some cleanup, mainly of nfsd_fh().  It was
> > long and complicated, now it's short and complicated.  We could probably
> > simplify the logic with a little more work.
> > 
> > --b.
> Which bug are you referring to?

Suppose /etc/exports contains:

	/foo		*(rw,crossmnt)
	/foo/bar	*(ro)

The "crossmnt" tells us to export all filesystems under /foo recursively
with the same options as /foo is exported with.  So there's a conflict:
should /foo/bar be exported ro, or rw?

The logical thing to do is to make the "ro" on the explicit export of
/foo/bar override the inherited "rw" from /foo, and in practice that's
what people have obviously expected in every case I've seen.

But we don't do that.  Actually, it's worse than that: the /foo export
wins in the nfsd_fh upcall, and the /foo/bar export wins in the
nfsd_export upcall.  So you can get inconsistent results depending on
which order things happen in.

So the first patch fixes nfsd_fh to behave like nfsd_export does, and
prefer /foo/bar.

This was most commonly a problem with people doing fsid=0 exports, so
it's less of a problem now that we have the v4root stuff, but definitely
it still needs fixing.

--b.
