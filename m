From: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>
Subject: RE: Re: lockd grace period
Date: Tue, 1 Feb 2005 17:22:08 +0530
Message-ID: <395A443A7CBF0246843BFD3471A8231DC01A28@bgeexc04.asiapacific.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <steved@redhat.com>, <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvweb-0003Dn-Fy
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 03:57:09 -0800
Received: from sngrel5.hp.com ([192.6.86.210])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CvweY-0004Fy-O5
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 03:57:09 -0800
To: "mehta kiran" <kiranmehta1981@yahoo.com>
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

Mehta kiran wrote :=20

>**Can anybody let me know what the standard behaviour
>  should be. ??

I think lockd should enter grace period, in the current scenario.

But I would like the lockd to be transparent to nfs client and nfs
server.
In that way it can act as client and server transparently.
Would that be a better way than existing one ?

~Chetan


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
