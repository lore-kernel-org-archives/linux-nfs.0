From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should fcntl operations check attributes with the server
	when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 15:19:29 -0500
Message-ID: <1140725969.7963.17.camel@lade.trondhjem.org>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
	 <1140711133.11831.27.camel@lade.trondhjem.org>
	 <20060223192253.GG29177@hmsendeavour.rdu.redhat.com>
	 <1140723567.7963.13.camel@lade.trondhjem.org> <43FE11F1.5040005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCMwF-0006yE-3s
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 12:19:47 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCMwC-0002YV-Fv
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 12:19:46 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43FE11F1.5040005@redhat.com>
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

On Thu, 2006-02-23 at 14:50 -0500, Peter Staubach wrote:
> Trond Myklebust wrote:
> 
> >
> >It is not worth fixing. There is currently no support for using
> >fcntl(F_SETLEASE) in an NFS shared environment, and there are no plans
> >to support it unless at some point we get NFS protocol support for it.
> >
> >Leases will currently work as expected in an NFS environment where a
> >single client has exclusive access to the file (and hence where local
> >locking works), but that is all.
> >
> >In the scenario you describe, we would need NFS protocol support in
> >order to get leases to work at all. This is due to the fact that under
> >the lease model, the process holding the lease expects to be notified
> >_synchronously_ of any conflicting open() calls, renames, mode changes,
> >truncate calls, etc to the file. By "synchronously", I mean that the
> >notification must come _before_ the server actually performs the change.
> >
> >The EACCESS race that you describe should be the very least of your
> >worries.
> >
> 
> I would disagree somewhat.  There is a customer who has stumbled into this
> situation.  We know that there is a bug here, that it has affected at one
> customer, and the risk for fixing it is very small.  The gains might not be
> obvious, but it would make at one customer even slightly happier.  That's
> worth the small amount of effort that it would take to fix this.

Will the customer be happy to find out that the application breaks in
much more nefarious ways as a result of a non-working lease?

If this is Samba, then the correct answer is obvious: turn off oplocks
in the configuration file since they won't ever work as expected anyway.

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
