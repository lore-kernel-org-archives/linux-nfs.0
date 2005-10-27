From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data coherency
	trouble	with	multiple	clients,	on2.6.14-rc5
Date: Thu, 27 Oct 2005 08:53:13 -0400
Message-ID: <1130417594.14036.20.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>
	 <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com>
	 <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com>
	 <1130360742.8859.56.camel@lade.trondhjem.org> <435FF3B1.5030200@redhat.com>
	 <1130363854.8956.23.camel@lade.trondhjem.org> <4360C739.5010403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV7GJ-0006oc-HV
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:53:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EV7GH-0003n2-AP
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:53:43 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4360C739.5010403@redhat.com>
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

to den 27.10.2005 klokka 08:25 (-0400) skreiv Peter Staubach:
> >See my recent proposal for NFSv4 "byte range delegations" at the IETF
> >RFC website. If people want NFS to have full posix cache semantics, then
> >we can certainly add that capability. ;-)
> >
> 
> I'll have to take a closer look.  Is this a performance thing over the
> normal whole file delegations?

No. It is dealing with caching in an environment where you may have
possibly multiple readers and writers to the same file. In such an
environment, the file delegation model cannot function at all.

Basically the proposal adds support for safe write-behind and read
caching by allowing the client to set up a lease on ranges of cached
data. The server is given the ability to notify the client whenever it
needs to write back the dirty data and/or clear its read cache.
See
http://www.ietf.org/internet-drafts/draft-myklebust-nfsv4-byte-range-delegations-00.txt

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
