From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: intercepting NFS RPC requests
Date: Tue, 7 Nov 2006 10:50:54 -0800
Message-ID: <9c8209a10611071050p475a2cf1y6656153a4b6a24e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2008792933=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhW2H-0001Ux-DJ
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 10:51:02 -0800
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GhW2G-0006WV-1S
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 10:51:02 -0800
Received: by nf-out-0910.google.com with SMTP id c31so323577nfb
	for <nfs@lists.sourceforge.net>; Tue, 07 Nov 2006 10:50:54 -0800 (PST)
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

--===============2008792933==
Content-Type: multipart/alternative;
	boundary="----=_Part_13557_14150320.1162925454353"

------=_Part_13557_14150320.1162925454353
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi

Is there a feature on the linux v3 or v4 NFS server to allow a process to
intercept the NFS RPC requests for file operations (open, close, read, write
etc) and handle them in user space? If so, can these be handled
asynchronously?

Alternatively, if this is not possible, is this achievable through VFS
i.ehave a process create and register a file system through VFS and
export it
through NFS? Now when the server handles a client's file operation, it goes
through VFS and ends up with that vector registered by that process?

Thx,
MB

------=_Part_13557_14150320.1162925454353
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi<br><br>Is there a feature on the linux v3 or v4 NFS server to allow a process to intercept the NFS RPC requests for file operations (open, close, read, write etc) and handle them in user space? If so, can these be handled asynchronously?
<br><br>Alternatively, if this is not possible, is this achievable through VFS i.e have a process create and register a file system through VFS and export it through NFS? Now when the server handles a client's file operation, it goes through VFS and ends up with that vector registered by that process?
<br><br>Thx,<br>MB<br><br>

------=_Part_13557_14150320.1162925454353--


--===============2008792933==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============2008792933==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2008792933==--
