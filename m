From: "Lever, Charles" <cel@netapp.com>
Subject: RE: Re: more on silly names
Date: Sat, 4 Sep 2004 16:46:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E768@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3kEe-00039c-41
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 16:46:20 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C3kEb-00031o-TK
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 16:46:20 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
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

> If mmapped data needs to be committed to disk before the=20
> flushd/pdflush daemon gets round to doing it, you need to=20
> explicitly call msync().

msync() is broken on NFS files before 2.4.24-ish.  so be sure you are on
a recent kernel, or are running the latest update of RHEL 3.0, if you
need msync() to work correctly.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
