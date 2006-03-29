From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 09:44:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1600035005-1143618245=:2597"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOVLk-0004ZQ-AE
	for nfs@lists.sourceforge.net; Tue, 28 Mar 2006 23:44:16 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOVLh-0007X9-PB
	for nfs@lists.sourceforge.net; Tue, 28 Mar 2006 23:44:16 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 2F03125DB23
	for <nfs@lists.sourceforge.net>; Wed, 29 Mar 2006 09:44:05 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1600035005-1143618245=:2597
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable


Hi. We are using unfsd to provide "personal" mounts in a thin client=20
environment, based on NFSv3 over TCP over SSH. This works fairly good, bu=
t=20
we would like a little shorter timeout when the server doesn't respond=20
(such as when the user has disabled file sharing and thus stopped unfsd).=
=20
Currently, we are mounting with:

rw,noexec,nosuid,nodev,port=3DXXXX,mountport=3DXXXX,mountvers=3D3,nfsvers=
=3D3,nolock,fg,soft,intr,tcp,actimeo=3D2,addr=3D127.0.0.1

The important options wrt timeout here is:

fg,soft,intr,tcp

So, we are not using timeo or retrans at all. The result is timeouts=20
varying between 3 and 180 seconds. The worst case seems to be when doing =
a=20
"kill -STOP" on unfsd (thus, simply not respond, in contrast to respond=20
with EOF or similiar).

My questions are:

* How can we lower the timeouts? To me, it seems like the hardcoded
   maximum timeout of 60 seconds is a bit of a problem. How about
   introducing an option for changing this?

   If we start using, say, retrans=3D1, does this mean that applications =
can
   recieve EIO after as little as 1 second?


* Is it true that all the "-f" option to umount does is skip trying
   MOUNTPROC_UMNT?


* About "intr": The man page says "If an NFS file operation has a major
   timeout and it is hard mounted". Does "intr" affect soft mounts in any
   way, or is it better to remove it?


Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1600035005-1143618245=:2597--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
