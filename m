From: "Jeroen Maris" <jamaris@gmail.com>
Subject: NFS specifically slow
Date: Mon, 13 Nov 2006 23:41:09 +0100
Message-ID: <b03954e20611131441wd602331na2ecac03cf3c7578@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1410956872=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjkUH-00039M-IJ
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 14:41:09 -0800
Received: from nz-out-0102.google.com ([64.233.162.206])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GjkUI-0002iC-Hw
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 14:41:10 -0800
Received: by nz-out-0102.google.com with SMTP id i11so1426514nzi
	for <nfs@lists.sourceforge.net>; Mon, 13 Nov 2006 14:41:10 -0800 (PST)
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

--===============1410956872==
Content-Type: multipart/alternative;
	boundary="----=_Part_110829_15172855.1163457669811"

------=_Part_110829_15172855.1163457669811
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hey.
I have a server with a raid5 array, consisting of 5 x 500 GB mounted as
/directory.
I export this directory in /etc/exports as "/array 192.168.1.2
(rw,sync,no_root_squash)".
On the client it is mounted with "server:/directory/ /directory nfs
rw,rsize=8192,wsize=8192,timeo=14,intr,hard 0 0"

Read performance is good; approximately 30 MB/s.
Write performance is very poor; approximately 5 MB/s.

Now, I tested with another server, and guess what: read & write performance
both 30 MB/s if I copy something from my homedirectory (reiserfs) to the NFS
directory.
When copying something from another disk on my client (ntfs) to the same NFS
directory, write performance goes down to 5 MB/s.
Again copying something from my homedirectory to the NFS directory results
in 30 MB/s.

Now, I exported the homedirectory on my server and repeated the test.
The server read/write performance were good; approximately 30 MB/s (this is
copying from client homedirectory to server homedirectory)
Then, copying something from client homedirectory to the server directory
(not homedir, the first one), read speed is 30 MB/s, write speed is 5 MB/s.

What's going on?

------=_Part_110829_15172855.1163457669811
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hey.<br>I have a server with a raid5 array, consisting of 5 x 500 GB mounted as /directory.<br>I export this directory in /etc/exports as &quot;/array 192.168.1.2(rw,sync,no_root_squash)&quot;.<br>On the client it is mounted with &quot;server:/directory/ /directory nfs rw,rsize=8192,wsize=8192,timeo=14,intr,hard 0 0&quot;
<br><br>Read performance is good; approximately 30 MB/s.<br>Write performance is very poor; approximately 5 MB/s.<br><br>Now, I tested with another server, and guess what: read &amp; write performance both 30 MB/s if I copy something from my homedirectory (reiserfs) to the NFS directory.
<br>When copying something from another disk on my client (ntfs) to the same NFS directory, write performance goes down to 5 MB/s.<br>Again copying something from my homedirectory to the NFS directory results in 30 MB/s.<br>
<br>Now, I exported the homedirectory on my server and repeated the test.<br>The server read/write performance were good; approximately 30 MB/s (this is copying from client homedirectory to server homedirectory)<br>Then, copying something from client homedirectory to the server directory (not homedir, the first one), read speed is 30 MB/s, write speed is 5 MB/s.
<br><br>What's going on?<br>

------=_Part_110829_15172855.1163457669811--


--===============1410956872==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1410956872==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1410956872==--
