From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should fcntl operations check attributes with the server
	when NFS shares are mounted noac?
Date: Fri, 24 Feb 2006 10:39:49 -0500
Message-ID: <1140795589.3615.31.camel@lade.trondhjem.org>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
	 <1140711133.11831.27.camel@lade.trondhjem.org>
	 <20060223192253.GG29177@hmsendeavour.rdu.redhat.com>
	 <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com>
	 <1140725969.7963.17.camel@lade.trondhjem.org> <43FE2029.7040205@redhat.com>
	 <1140733881.7963.31.camel@lade.trondhjem.org>
	 <20060224140615.GA31881@hmsendeavour.rdu.redhat.com>
	 <1140791215.3615.20.camel@lade.trondhjem.org>
	 <20060224152514.GB31881@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCf3B-00073B-U8
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 07:40:09 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCf3A-0008Tj-E3
	for nfs@lists.sourceforge.net; Fri, 24 Feb 2006 07:40:10 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20060224152514.GB31881@hmsendeavour.rdu.redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 2006-02-24 at 10:25 -0500, Neil Horman wrote:

> > > 1) Fix the noac problem as previously described
> > > 2) Add a check (simmilar to that of flock) such that attempting to set a lease
> > > on a file over NFS results in a return of -ENOTSUPP or another appropriate
> > > error.
> > 
> > Why waste time doing (1) at all, since a "noac" mount usually means you
> > are in a situation where (2) applies?
> > 
> If this problem only exists on NFS, then I'd tend to agree.  Although again, it
> would seem that other multi-access file systems are going to suffer from the
> same drawback since we never call to the underlying filesystem to get the latest
> attributes.  two nodes could access a file in OCFS or GFS in the same way, and I
> would expect the same problem would occur.  Do you agree?

...and I would say if so, then the exact same argument applies: you are
in a situation where the whole lease concept is broken.

Leases are _not_ the same as locks: they are not designed for
synchronisation purposes, but rather as a cache consistency device. In
all the situations you have described so far there is no possibility for
maintaining even local cache consistency.

As for returning ENOTSUPP, I'm sceptical to that too: that is a radical
change in user behaviour that can also affect systems where the lease
use _is_ valid (i.e. the single client case).
The time to fix all this is when at least one of the above filesystems
develops protocol support for leases and finds that it needs a lease
callback, not before.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
