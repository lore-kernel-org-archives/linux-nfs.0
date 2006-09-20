From: "Adam Olsen" <arolsen@gmail.com>
Subject: NFS High Avialability without DRBD
Date: Wed, 20 Sep 2006 10:50:14 -0600
Message-ID: <2473b43f0609200950x533d059bw5029ab268fa9ca74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0011686725=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQ5H7-0007TZ-GE
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 09:50:17 -0700
Received: from wr-out-0506.google.com ([64.233.184.232])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQ5H8-0002i4-5Z
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 09:50:18 -0700
Received: by wr-out-0506.google.com with SMTP id 57so155988wri
	for <nfs@lists.sourceforge.net>; Wed, 20 Sep 2006 09:50:15 -0700 (PDT)
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

--===============0011686725==
Content-Type: multipart/alternative;
	boundary="----=_Part_79804_10115043.1158771014339"

------=_Part_79804_10115043.1158771014339
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

We'd like to have a highly available NFS server using heartbeat /without/
DRBD.  We've used DRBD in the past, and for this situation, it's just not
the best solution.

We have two machines, one mirroring the other with the occasional rsync.  If
the main server goes down, we'd like to have heartbeat failover to the
slave.  The data does not need to be exact on the slave.... if it's a day or
two behind, it won't really matter - it just needs to be up.

What is the best way of going about this?  What documentation would be best
to read?

Adam

------=_Part_79804_10115043.1158771014339
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,<br><br>We'd like to have a highly available NFS server using heartbeat /without/ DRBD.&nbsp; We've used DRBD in the past, and for this situation, it's just not the best solution.<br><br>We have two machines, one mirroring the other with the occasional rsync.&nbsp; If the main server goes down, we'd like to have heartbeat failover to the slave.&nbsp; The data does not need to be exact on the slave.... if it's a day or two behind, it won't really matter - it just needs to be up.
<br><br>What is the best way of going about this?&nbsp; What documentation would be best to read?<br><br>Adam<br>

------=_Part_79804_10115043.1158771014339--


--===============0011686725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0011686725==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0011686725==--
