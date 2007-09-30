From: "Yakov Lerner" <iler.ml@gmail.com>
Subject: filetimes after creat()
Date: Sun, 30 Sep 2007 12:56:27 +0200
Message-ID: <f36b08ee0709300356o2256a044lbf518034a303138@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0252847454=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbwTI-0003fy-HG
	for nfs@lists.sourceforge.net; Sun, 30 Sep 2007 03:56:25 -0700
Received: from wa-out-1112.google.com ([209.85.146.182])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbwTM-0007rk-IZ
	for nfs@lists.sourceforge.net; Sun, 30 Sep 2007 03:56:29 -0700
Received: by wa-out-1112.google.com with SMTP id k22so6380512waf
	for <nfs@lists.sourceforge.net>; Sun, 30 Sep 2007 03:56:28 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0252847454==
Content-Type: multipart/alternative;
	boundary="----=_Part_6987_30276570.1191149787722"

------=_Part_6987_30276570.1191149787722
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Assume the GMT time on server != GMT time on the client.
I do creat() then stat(). Which filetimes I am supposed to see:
server time or client time ? Is the answer same for atime, mtime, and ctime
?

Thanks
Yakov

------=_Part_6987_30276570.1191149787722
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Assume the GMT time on server != GMT time on the client.<br>I do creat() then stat(). Which filetimes I am supposed to see:<br>server time or client time ? Is the answer same for atime, mtime, and ctime ?<br><br>Thanks<br>
Yakov<br><br><br>

------=_Part_6987_30276570.1191149787722--


--===============0252847454==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0252847454==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0252847454==--
