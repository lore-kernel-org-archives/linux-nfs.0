From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs performance problem
Date: Tue, 5 Nov 2002 12:56:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55061@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189AkC-0007fi-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 12:56:16 -0800
To: "'Matt Heaton'" <admin@0catch.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> Cachefs will help quite a lot in my opinion because it 
> doesn't just store
> the files in RAM,
> it uses the hard drive.  So if you have an NFS client with an 
> extra 5 gig
> that you can
> designate as cache then reads to the NFS server will go down 
> DRAMATICALLY as
> it will hit local cache on the NFS clients drive.

yes, that's true, until you consider that without something
like v4 delegation, the client still has to contact the server
to keep its cache up to date.

matt, you really do want a faster server in this case.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
