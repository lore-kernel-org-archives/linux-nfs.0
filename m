From: "Dan Goetzman" <dan.goetzman@gmail.com>
Subject: NFS client problems with Tru64 NFS server
Date: Mon, 29 Jan 2007 15:42:42 -0600
Message-ID: <63f285650701291342w396ae046t1d38de91ec4345fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1085250644=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBeGy-0000ad-8k
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 13:42:44 -0800
Received: from an-out-0708.google.com ([209.85.132.246])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBeGy-0001k5-IB
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 13:42:45 -0800
Received: by an-out-0708.google.com with SMTP id d40so1313024and
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 13:42:43 -0800 (PST)
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

--===============1085250644==
Content-Type: multipart/alternative;
	boundary="----=_Part_141930_28992053.1170106962534"

------=_Part_141930_28992053.1170106962534
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using 2.6.19-1.2895.fc6 I have problems with Tru64 NFS file servers using
recent Linux NFS clients. I get the error "Not a directory" when I try to cd
to various sub dirs on the NFS filesystem. The problem, I think,  appears to
be that the NFS client code detects the directory is on a different
filesystem (it is not). Or at least that is what it appears like to me. The
problem remains for a given mount once a sub directory has this problem. A
umount/mount will clear the problem but then I will see in on another sub
directory.

I think the Linux NFS client might not be handling the Tru64 FSID's
correctly?
The output of /proc/fs/nfsfs/volumes for the remote NFS filesystem appears
like;

NV SERVER   PORT DEV     FSID
v3 ac13cc8d  801 0:18    6bb2b101:0
v3 ac13110f  801 0:36    ffffffffcc98e21e

 Note the second V3 mount, the FSID returned by the Tru64 server is not
displayed with the fsid major and fsid minor format. I checked with a
network trace and this "ffffffffcc98e211e" is in fact the correct FSID
returned by the Tru64 NFS server (using ADVFS filesystems). This problem
only appears on NFSV3, not NFSV2 and seems to be only with recent Linux
kernels (seen here in Fedora Core 6 and I have seen the same with RHAS 5).

Dan Goetzman

------=_Part_141930_28992053.1170106962534
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using 2.6.19-1.2895.fc6 I have problems with Tru64 NFS file servers using recent Linux NFS clients. I get the error &quot;Not a directory&quot; when I try to cd to various sub dirs on the NFS filesystem. The problem, I think,&nbsp; appears to be that the NFS client code detects the directory is on a different filesystem (it is not). Or at least that is what it appears like to me. The problem remains for a given mount once a sub directory has this problem. A umount/mount will clear the problem but then I will see in on another sub directory.
<br><br>I think the Linux NFS client might not be handling the Tru64 FSID&#39;s correctly?<br>The output of /proc/fs/nfsfs/volumes for the remote NFS filesystem appears like;<br><br>NV SERVER&nbsp;&nbsp; PORT DEV&nbsp;&nbsp;&nbsp;&nbsp; FSID<br>v3 ac13cc8d&nbsp; 801 0:18&nbsp;&nbsp;&nbsp; 6bb2b101:0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<br>v3 ac13110f&nbsp; 801 0:36&nbsp;&nbsp;&nbsp; ffffffffcc98e21e<br><br>&nbsp;Note the second V3 mount, the FSID returned by the Tru64 server is not displayed with the fsid major and fsid minor format. I checked with a network trace and this &quot;ffffffffcc98e211e&quot; is in fact the correct FSID returned by the Tru64 NFS server (using ADVFS filesystems). This problem only appears on NFSV3, not NFSV2 and seems to be only with recent Linux kernels (seen here in Fedora Core 6 and I have seen the same with RHAS 5).
<br><br>Dan Goetzman<br><br>&nbsp;<br>

------=_Part_141930_28992053.1170106962534--


--===============1085250644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1085250644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1085250644==--
