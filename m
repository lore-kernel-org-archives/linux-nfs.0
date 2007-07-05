From: "Myles Uyema" <mlists@uyema.net>
Subject: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Thu, 5 Jul 2007 14:01:28 -0700
Message-ID: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1544609742=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6YSA-0006kv-5a
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:01:30 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6YSB-0006NB-Kw
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:01:33 -0700
Received: by ug-out-1314.google.com with SMTP id m2so594219uge
	for <nfs@lists.sourceforge.net>; Thu, 05 Jul 2007 14:01:29 -0700 (PDT)
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

--===============1544609742==
Content-Type: multipart/alternative;
	boundary="----=_Part_136635_8844159.1183669288319"

------=_Part_136635_8844159.1183669288319
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

If I understand the explanation of the 'noacl' parameter, it should prevent
ACCESS calls right?  I'm not seeing this occurring on Fedora Core 7 (
2.6.21-1.3228.fc7 #1 SMP Tue Jun 12 14:56:37 EDT 2007 x86_64 x86_64 x86_64
GNU/Linux)

I mounted using tcp,noacl,rsize=32768,wsize=32768.  The NFS server is a
NetApp filer running 7.2.1.1, and is a unix-only filesystem.

Then I ran a script to 'dd' 286 files on the NFS mountpoint.  The script ran
as UID 48.
340 reads
286 getattr
286 access

The nfsstat showed my client still performing ACCESS calls.  I'd like to
believe that the GETATTR has already verified the permission bits, and thus
an ACCESS shouldn't be necessary.

------=_Part_136635_8844159.1183669288319
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

If I understand the explanation of the &#39;noacl&#39; parameter, it should prevent ACCESS calls right?&nbsp; I&#39;m not seeing this occurring on Fedora Core 7 (2.6.21-1.3228.fc7 #1 SMP Tue Jun 12 14:56:37 EDT 2007 x86_64 x86_64 x86_64 GNU/Linux)
<br><br>I mounted using tcp,noacl,rsize=32768,wsize=32768.&nbsp; The NFS server is a NetApp filer running 
<a href="http://7.2.1.1" target="_blank" onclick="return top.js.OpenExtLink(window,event,this)">7.2.1.1</a>, and is a unix-only filesystem.<br><br>Then I ran a script to &#39;dd&#39; 286 files on the NFS mountpoint.&nbsp; The script ran as UID 48.
<br>340 reads<br>286 getattr<br>286 access<br><br>The nfsstat showed my client still performing ACCESS calls.&nbsp; I&#39;d like to believe that the GETATTR has already verified the permission bits, and thus an ACCESS shouldn&#39;t be necessary.
<br>

------=_Part_136635_8844159.1183669288319--


--===============1544609742==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1544609742==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1544609742==--
