From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data coherency
	trouble	with	multiple	clients,	on2.6.14-rc5
Date: Thu, 27 Oct 2005 11:33:36 -0400
Message-ID: <1130427216.16359.54.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>
	 <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com>
	 <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com>
	 <1130360742.8859.56.camel@lade.trondhjem.org> <435FF3B1.5030200@redhat.com>
	 <1130363854.8956.23.camel@lade.trondhjem.org>  <4360E366.90200@sun.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV9lW-0005hv-C0
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 08:34:06 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EV9lS-0004to-0W
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 08:34:03 -0700
To: Calum Mackay <calum.mackay@sun.com>
In-Reply-To: <4360E366.90200@sun.com>
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

to den 27.10.2005 klokka 15:25 (+0100) skreiv Calum Mackay:
> > The NFSv4 change attribute may be returned atomically for some
> > operations (mainly those that modify a directory, such as CREATE,
> > OPEN,...).
> > Unfortunately it is not returned atomically for the case of the WRITE
> > operation.
> 
> I'm imagine that's for performance reasons? Do we have any experience as 
> to what sort of difference this makes, in practice?

If your clients have to collect the pre- and post-op change attribute
using GETATTR ops before and after the WRITE op in the "write" COMPOUND,
then there can be a fairly large race.
Most servers will serialise the WRITE ops w.r.t. each other, so a
typical race would be 2 server threads processing simultaneous write
requests to the same file from 2 different clients:

Client 1                              Client 2
--------                              --------
OP_GETATTR			OP_GETATTR
				OP_WRITE (bumps change attr)
OP_WRITE (bumps change attr)		OP_GETATTR
OP_GETATTR

When this happens, client 1 and client 2 both see the correct pre-op
change attribute, but client 1 just sees the post-op change attribute
that results from _both_ writes (client 2 may or may not do the same).
It will therefore miss the fact that its cache is now invalid.
Probably a rare occurrence in general, but definitely a problem if you
are writing a database application.

The same race could not occur with NFSv3's weak cache consistency
(assuming the servers implement it according to spec).

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
