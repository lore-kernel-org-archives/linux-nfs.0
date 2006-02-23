From: Peter Staubach <staubach@redhat.com>
Subject: Re: Should fcntl operations check attributes with the server
 when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 14:50:09 -0500
Message-ID: <43FE11F1.5040005@redhat.com>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>	 <1140711133.11831.27.camel@lade.trondhjem.org>	 <20060223192253.GG29177@hmsendeavour.rdu.redhat.com> <1140723567.7963.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Horman <nhorman@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCMTj-0003ae-Me
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:50:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCMTi-0006F8-ID
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 11:50:19 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140723567.7963.13.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>
>It is not worth fixing. There is currently no support for using
>fcntl(F_SETLEASE) in an NFS shared environment, and there are no plans
>to support it unless at some point we get NFS protocol support for it.
>
>Leases will currently work as expected in an NFS environment where a
>single client has exclusive access to the file (and hence where local
>locking works), but that is all.
>
>In the scenario you describe, we would need NFS protocol support in
>order to get leases to work at all. This is due to the fact that under
>the lease model, the process holding the lease expects to be notified
>_synchronously_ of any conflicting open() calls, renames, mode changes,
>truncate calls, etc to the file. By "synchronously", I mean that the
>notification must come _before_ the server actually performs the change.
>
>The EACCESS race that you describe should be the very least of your
>worries.
>

I would disagree somewhat.  There is a customer who has stumbled into this
situation.  We know that there is a bug here, that it has affected at one
customer, and the risk for fixing it is very small.  The gains might not be
obvious, but it would make at one customer even slightly happier.  That's
worth the small amount of effort that it would take to fix this.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
