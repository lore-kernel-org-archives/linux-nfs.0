From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 00 of 11] nfs-utils: mount comand patches.
Date: Mon, 26 Feb 2007 06:17:04 -0500
Message-ID: <45E2C1B0.7030507@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060308040904070303070903"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdoR-0000BI-Pi
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:36 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdoS-000647-Ih
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:37 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEUMG000402
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:30 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEU7U005347
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:30 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBET50025439
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:29 -0500
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060308040904070303070903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Some time ago, we enabled the mounting code in nfs-utils during
a couple of our releases. The following patch series contains the
patch that fix the problems we found during those processes...

All of these patches have been committed the following git tree:

git://git.infradead.org/~steved/nfs-utils.git

Attached to this email are all the commit blobs that
are in this patch series...

steved.

P.S. I will be subjecting my family to send a few days
with me... x-sking in Vermont... So I will not be able
to reply to any comments on these patches until later
this week...


--------------060308040904070303070903
Content-Type: text/plain;
 name="blobs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="blobs"

806b02f63fe6e01946d84a1f14c74e977be76530
eaa8dade2651ec9df1c9513e63ef2d9ae5c5d980
72baf6d14f166da0531bfe02273861e1c394c3bd
999dfb7ece03bee326579b678b9a83a2ad598fef
200d810e3fa2c7f35932faac87a6409fac5a9d4d
0ffd74c990aca3761b79316d47e1b1778273681c
d507c76527acc3415395cd70cc08d02e32dbe181
84e8186d1ad1f280c2a849349efbddab1f1fe16d
253c6b866a1ed4678c30131a41ef96821bae9d5f
7f9cc56de079b1c53f912fc2abe31203e79782f4
96a3ceb3d35bf5edcb9446aded8375d3b98b4f5b

--------------060308040904070303070903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060308040904070303070903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060308040904070303070903--
