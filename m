From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data coherency trouble with multiple
	clients,	on2.6.14-rc5
Date: Wed, 26 Oct 2005 15:08:13 -0400
Message-ID: <1130353693.8859.21.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>
	 <1130345451.8852.7.camel@lade.trondhjem.org>  <435FCECF.2090800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUqdz-0003VO-5x
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 12:09:03 -0700
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUqdu-0007lz-0c
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 12:09:03 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <435FCECF.2090800@redhat.com>
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

on den 26.10.2005 klokka 14:45 (-0400) skreiv Peter Staubach:

> It seems to me that the policy should be to allow cache 
> validation/invalidation
> unless the file is mmap'd for writing or if there are active WRITEs 
> outstanding.
> Simply having the file open for write should not affect the consistency 
> model.

That is what we did for 2.4.x, but what kind of extra guarantees does
that really bring you? You cannot actually rely on it to provide
stronger caching semantics than the close-to-open case.

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
