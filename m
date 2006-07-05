From: "Alan Cota" <alancota@gmail.com>
Subject: NFS problem - "suspicion"
Date: Wed, 5 Jul 2006 13:57:19 -0300
Message-ID: <fb6f32220607050957v73de204dxf45659199f5e51c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1945409615=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyAmS-0005Kv-I2
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 10:03:16 -0700
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyAmR-0005B3-0t
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 10:03:16 -0700
Received: by ug-out-1314.google.com with SMTP id j40so2165692ugd
	for <nfs@lists.sourceforge.net>; Wed, 05 Jul 2006 10:03:12 -0700 (PDT)
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

--===============1945409615==
Content-Type: multipart/alternative;
	boundary="----=_Part_67368_23489704.1152118639182"

------=_Part_67368_23489704.1152118639182
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all.
I'm a IT consultant and now I'm working in a Novell product project. Novell
have a colaboration system called Groupwise. This system runs in Linux (Suse
9) server and all of the Groupwise files are in a Sun Storage and my Suse
server access these files using NFS. This is the reply of "uname -na"
command: Linux gwserver 2.6.5-7.252-smp #1 SMP Tue Feb 14 11:11:04 UTC 2006
i686 i686 i386 GNU/Linux

This is my commands, inside /etc/fstab file to mount the storage data
volumes:

10.0.0.1:/vol/mail01      /mnt/mail01     nfs
defaults,rsize=8192,wsize=8192,hard,tcp,nolock 0 0
10.0.0.1:/vol/mail01/grpwise      /usr/novell/sys/grpwise nfs
defaults,rsize=8192,wsize=8192,tcp,hard,nolock 0 0

My problem is the database corruption of my Groupwise system.
Is there anyway to get logs about NFS to verify if the problem is or not
about NFS.

Thank you!

My best regards,


-- 
Atc,

Alan Cota.
alancota@gmail.com
+55 27 8118-3720

------=_Part_67368_23489704.1152118639182
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all.<br>I'm a IT consultant and now I'm working in a Novell product project. Novell have a colaboration system called Groupwise. This system runs in Linux (Suse 9) server and all of the Groupwise files are in a Sun Storage and my Suse server access these files using NFS. This is the reply of &quot;uname -na&quot; command: Linux gwserver 
2.6.5-7.252-smp #1 SMP Tue Feb 14 11:11:04 UTC 2006 i686 i686 i386 GNU/Linux<br><br>This is my commands, inside /etc/fstab file to mount the storage data volumes:<br><br>10.0.0.1:/vol/mail01&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /mnt/mail01&nbsp;&nbsp;&nbsp;&nbsp; nfs&nbsp;&nbsp;&nbsp;&nbsp; defaults,rsize=8192,wsize=8192,hard,tcp,nolock 0 0
<br>10.0.0.1:/vol/mail01/grpwise&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /usr/novell/sys/grpwise nfs&nbsp;&nbsp;&nbsp;&nbsp; defaults,rsize=8192,wsize=8192,tcp,hard,nolock 0 0<br><br>My problem is the database corruption of my Groupwise system.<br>Is there anyway to get logs about NFS to verify if the problem is or not about NFS.
<br><br>Thank you!<br><br>My best regards,<br><br clear="all"><br>-- <br>Atc,<br><br>Alan Cota.<br><a href="mailto:alancota@gmail.com">alancota@gmail.com</a><br>+55 27 8118-3720

------=_Part_67368_23489704.1152118639182--


--===============1945409615==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1945409615==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1945409615==--
