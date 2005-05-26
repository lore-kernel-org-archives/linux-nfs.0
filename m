From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS cache problem
Date: Wed, 25 May 2005 18:21:51 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539BA7@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Db74Q-0000e7-P5
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 18:21:58 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Db74P-00042r-HO
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 18:21:58 -0700
To: "Anton Starikov" <A.Starikov@utwente.nl>
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

hi anton-

> I use ReiserFS.
> And here we talk not about seconds...we talk about hours sometimes.
> That's seems too strange for me. For seconds I can find plenty of
> explanations :)
> In principal even if it will be one minute, I'll be much more=20
> happy than
> now.

> > If you seriously need uncached reads and writes, then you=20
> should rather,
> > consider using O_DIRECT.
> Unfortunatelly this is not trivial problem. A lot of software are
> involved here. And I beleive that NFS should be able to work in this
> conditions properly. At least it did with solaris in similar=20
> environment.

if you have a way of reproducing this condition, maybe you could capture
a network trace on the server while running your test case...  "tcpdump
-s0 -w dumpfile" and post it on the web so we can take a look at what's
going on.


-------------------------------------------------------
SF.Net email is sponsored by: GoToMeeting - the easiest way to collaborate
online with coworkers and clients while avoiding the high cost of travel and
communications. There is no equipment to buy and you can meet as often as
you want. Try it free.http://ads.osdn.com/?ad_id=7402&alloc_id=16135&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
