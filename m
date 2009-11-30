From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Mon, 30 Nov 2009 17:13:58 -0500
Message-ID: <20091130221358.GH7332@fieldses.org>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com> <4B13C48E.5020009@RedHat.com> <20091130181858.GA6348@fieldses.org> <20091201085916.7c1bb644@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbZK3WNB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 17:13:01 -0500
In-Reply-To: <20091201085916.7c1bb644-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 01, 2009 at 08:59:16AM +1100, Neil Brown wrote:
> On Mon, 30 Nov 2009 13:18:58 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Note we want to do more than one of these; in particular:
> > 
> > >    1) Start servers with '-N 4' when there is no root configured.  
> > 
> > This is required.  The current behavior is a bug, and we must not
> > start servers with v4 support without having a pseudoroot.
> 
> Yes, you could describe the current behaviour as a bug, but I don't
> think it necessarily follows than encouraging the use of "-N 4" is an
> appropriate resolution to the bug.  I agree with Steve that that would
> seem like a backwards step.

I agree that there's a usability disadvantage, but basic correctness
trumps usability here.

> Completing the auto-pseudo-root work and getting that active would also
> fix the bug, and would do it in a more forward-looking way.

Yes, it's a huge problem that that hasn't been resolved yet, sorry.  I
hope we have close-to-final patches posted today or tomorrow.

By the way, on a possibly related problem: there is one corner case
where Steve's proposed approach won't work: when the filesystems
traversed on the way to the root don't themselves support nfs exports.
I'd expect that to be rare, but was surprised to see at least one person
reporting doing it:

	http://marc.info/?l=linux-nfs&m=125787146106897&w=2

As a last resort, some day we may need some way to turn off v4 in that
case.

> So while there may be a case of advising people (in a FAQ?) that using 
> -N4 might be appropriate if no fsid=root is configured, I don't think
> there is any point in trying to make it a default through making
> any changes to the nfs-utils packages.

All that's needed is a different default in e.g. /etc/sysconfig/nfs, and
a note that v4 servers need to adjust the default.  It's annoying, but
not that annoying.

--b.
