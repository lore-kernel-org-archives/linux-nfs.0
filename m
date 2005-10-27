From: Calum Mackay <calum.mackay@sun.com>
Subject: Re: Data coherency trouble	with	multiple	clients,	on2.6.14-rc5
Date: Thu, 27 Oct 2005 15:25:42 +0100
Message-ID: <4360E366.90200@sun.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com> <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com> <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com> <1130360742.8859.56.camel@lade.trondhjem.org> <435FF3B1.5030200@redhat.com> <1130363854.8956.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV8hZ-0002VM-O5
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 07:25:57 -0700
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EV8hT-0004i8-MZ
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 07:25:57 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1130363854.8956.23.camel@lade.trondhjem.org>
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
>> Actually NFSv4 does have an attribute that the client can use, doesn't it?
>> Something like change_attr or some such?
> 
> The NFSv4 change attribute may be returned atomically for some
> operations (mainly those that modify a directory, such as CREATE,
> OPEN,...).
> Unfortunately it is not returned atomically for the case of the WRITE
> operation.

I'm imagine that's for performance reasons? Do we have any experience as 
to what sort of difference this makes, in practice?

cheers,
calum.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
