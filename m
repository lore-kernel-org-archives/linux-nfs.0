From: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>
Subject: RE: lockd grace period
Date: Mon, 31 Jan 2005 18:20:20 +0530
Message-ID: <395A443A7CBF0246843BFD3471A8231DC0176D@bgeexc04.asiapacific.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvb0k-0003gP-6O
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:50:34 -0800
Received: from sngrel4.hp.com ([192.6.86.110])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cvb0h-0000Y6-C0
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:50:34 -0800
To: "Steve Dickson" <SteveD@redhat.com>,
	"mehta kiran" <kiranmehta1981@yahoo.com>
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

Steved wrote :

> Yes and Yes... When a NFS server is restarted, there is a grace period
in which the server (i.e. lockd) will accept reclaimed locks.
> And it appears that reclaimed locks will also be accepted after the
grace period expires=20

I think reclaim locks should not be accepted after the grace period
expires, because it can cause data corruption.

Say, a reclaim request arrives after grace period and get's lock. There
will be time frame between end of grace period and arrival of
Reclaim request, in which case any thing can happen(ex: a new request
could be granted, it may make some changes to a file and unlock by the
time Reclaim arrives).

In which case reclaim thinks that it was the same original file it had
last locked.

So reclaim after grace period is not a good idea.

Mehta's question :

>What is the expected behaviour.?
>Is it that whenever nfsd starts  , lockd should enter grace period ?
>or
>Is is that lockd should enter grace period only when it restarts=20
>without caring for nfs.?

The lockd should enter grace period whenever nfsd starts/restarts.

~Chetan


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
