From: "Venkatesh KS" <venkatesh.ks@gmail.com>
Subject: novice question about large write requests
Date: Fri, 2 Feb 2007 19:05:58 +0530
Message-ID: <4cf2912c0702020535i2b11691as8bc5ead997fa0d85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0508698857=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCyaB-0001Im-QU
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 05:36:04 -0800
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCyaD-0000Bq-FS
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 05:36:05 -0800
Received: by nf-out-0910.google.com with SMTP id c31so2257736nfb
	for <nfs@lists.sourceforge.net>; Fri, 02 Feb 2007 05:35:59 -0800 (PST)
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

--===============0508698857==
Content-Type: multipart/alternative;
	boundary="----=_Part_28747_9980944.1170423358493"

------=_Part_28747_9980944.1170423358493
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Folks,

I am trying to understand how nfs client handles a server reboot while
issuing multiple
unstable writes followed by a commit.

Say a user requests a large write requests.
nfs client breaks it into multiple 32k requests, each 32k write request
being unstable
and finally a commit call before the nfs client returns back to the user.

If the server reboots in between these write calls, will the nfs client know
abt it.
The write before this may not have made it to disk. If the nfs client doenst
know
abt it then it goes ahead with commit call and returns.

regards,
-venkatesh

------=_Part_28747_9980944.1170423358493
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Folks,<br><br>I am trying to understand how nfs client handles a server reboot while issuing multiple<br>unstable writes followed by a commit.<br><br>Say a user requests a large write requests.<br>nfs client breaks it into multiple 32k requests, each 32k write request being unstable
<br>and finally a commit call before the nfs client returns back to the user.<br><br>If the server reboots in between these write calls, will the nfs client know abt it.<br>The write before this may not have made it to disk. If the nfs client doenst know
<br>abt it then it goes ahead with commit call and returns.<br><br>regards,<br>-venkatesh<br><br><br>

------=_Part_28747_9980944.1170423358493--


--===============0508698857==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0508698857==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0508698857==--
