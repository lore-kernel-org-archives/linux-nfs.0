From: Christopher T Vogan <cvogan@us.ibm.com>
Subject: FileID size with nfsv3
Date: Fri, 12 Jan 2007 11:31:10 -0600
Message-ID: <OF3AC591FD.96801C6A-ON87257261.005FEDEB-86257261.00603911@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0055769411=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5QLG-0004Qt-BV
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 09:37:26 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H5QLG-0004pz-RW
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 09:37:28 -0800
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1H5QJc-0007lL-Ii
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 09:35:46 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0CHVEeK007311
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 12:31:14 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	l0CHVEia551832
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 10:31:14 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l0CHVE5b001010
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 10:31:14 -0700
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com
	[9.17.195.142])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l0CHVEPm000987
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 10:31:14 -0700
To: nfs@lists.sourceforge.net
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

--===============0055769411==
Content-type: multipart/alternative;
	Boundary="0__=08BBF8F2DFCC6B7B8f9e8a93df938690918c08BBF8F2DFCC6B7B"
Content-Disposition: inline

--0__=08BBF8F2DFCC6B7B8f9e8a93df938690918c08BBF8F2DFCC6B7B
Content-type: text/plain; charset=US-ASCII




I had a question regarding NFSv3 Client and server but was not sure who to
ask.
The NFSv3 RFC states that NFSv3 should support 8 byte FILEID's. Does Linux
support 8 byte FILEID's for NFSv3? It seems that most commands do support
the use of large FileID's but gcc seems to have a problem.

This is what I see in the RFC1813
File attribute changes from NFSv2.
The size and fileid fields have been widened to eight-byte unsigned
integers from four-byte integers.


--0__=08BBF8F2DFCC6B7B8f9e8a93df938690918c08BBF8F2DFCC6B7B
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt><br>
I had a question regarding NFSv3 Client and server but was not sure who to ask.<br>
The NFSv3 RFC states that NFSv3 should support 8 byte FILEID's. Does Linux<br>
support 8 byte FILEID's for NFSv3? It seems that most commands do support the use of large FileID's but gcc seems to have a problem. </tt><br>
<br>
<tt>This is what I see in the RFC1813<br>
File attribute changes from NFSv2.<br>
The size and fileid fields have been widened to eight-byte unsigned<br>
integers from four-byte integers.<br>
<br>
<br>
</tt></body></html>
--0__=08BBF8F2DFCC6B7B8f9e8a93df938690918c08BBF8F2DFCC6B7B--



--===============0055769411==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0055769411==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0055769411==--
