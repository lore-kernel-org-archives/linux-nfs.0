From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should fcntl operations check attributes with the server
	when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 11:12:13 -0500
Message-ID: <1140711133.11831.27.camel@lade.trondhjem.org>
References: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCJ58-0003HG-9L
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 08:12:42 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FCJ53-0007yP-EG
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 08:12:39 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
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

On Thu, 2006-02-23 at 07:42 -0500, Neil Horman wrote:
> Hey all-
> 	I've got a dillema and I'm not sure how to anwser it.  I recently had
> someone mention to me that some of the operations executed via fcntl
> (specifically F_SETLEASE was demonstrated to me) don't check the file attributes
> on the server before executing their operations.  This can lead to erroneous
> behavior in which, if someone updates file permissions or ownership from another
> node mounting an NFS share, a node attempting to do something like a F_SETLEASE
> operation will fail when it should succede, or vice versa.

Who is trying to use F_SETLEASE on an NFS share in these conditions? 

That is unbelievably borken: leases are supposed to guarantee that
nobody is changing the file. If the file is being changed on the server,
then exactly what use do they serve?

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
