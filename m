From: Genco YILMAZ <gyilmaz@beriltech.com>
Subject: Re: 230GB partition mount problem
Date: Fri, 31 Mar 2006 13:02:56 +0300
Message-ID: <442CFE50.1050802@beriltech.com>
References: <442CECE7.1040806@beriltech.com> <200603311057.21433.vincent.roqueta@bull.net>
Mime-Version: 1.0
Content-Type: text/html; charset=ISO-8859-9
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPGT8-0002VR-KO
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 02:03:02 -0800
Received: from mail.posta.tc ([85.111.0.146] helo=mira.yonlendir.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPGT7-0000rN-6y
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 02:03:02 -0800
To: Vincent Roqueta <vincent.roqueta@bull.net>
In-Reply-To: <200603311057.21433.vincent.roqueta@bull.net>
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

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content=3D"text/html;charset=3DISO-8859-9" http-equiv=3D"Content-=
Type">
  <title></title>
</head>
<body bgcolor=3D"#ffffff" text=3D"#000000">
Hello Vincent,<br>
=A0=A0=A0=A0 I have added nohide option but result is the same. (I have d=
one
"exportfs -r" and reload the deamon too) <br>
Actually, there are already two mounted partitions on the server under
/var/images;<br>
1)=A0 apachelogs (sdb1,ext3) <br>
2) uploads (sdb2,reiserfs)=A0 <br>
<br>
I can see uploads directory with no problem.=A0 Even if I have added
nohide, I cannot see apachelogs partition from the client (Kernel is
2.6.15.1 )<br>
=A0=A0=A0=A0 Do you have any idea why I cannot see it? If there were some
permission problems, I would probably receive a permission denied
problem but <br>
I can see the empty apachelogs directory. I am really confused. This
happens to me first time in my NFS experience. <br>
<br>
Kind Regards.<br>
<br>
<br>
<br>
Vincent Roqueta wrote:
<blockquote cite=3D"mid200603311057.21433.vincent.roqueta@bull.net"
 type=3D"cite">
  <pre wrap=3D"">Le Vendredi 31 Mars 2006 10:48, Genco YILMAZ a =E9crit=A0=
:
  </pre>
  <blockquote type=3D"cite">
    <pre wrap=3D"">Hello,
   I have mounted a partition from NFS server. The partitions on the
server is

/var/images/apachelogs
/var/images/www/uploads

/var/images is a directory on the / filesystem
apachelogs(ext3) is a 230GB partition with block size 1024KB and inode
count 30519296
uploads is a reiserfs file system.

My problem is :
       I mount /var/images directory to the client machine through NFS
server and I can see uploads folder but even if I have given all the
permissions on the source folder I cannot see any subdirectory in the
apachelogs folder as if there is nothing in it.

My mount options:
noauto,nolock,nosuid,noexec,rw,hard,intr,rsize=3D1024,wsize=3D1024 0 0
Server parameters exportfs: (rw,sync,no_subtree_check,no_root_squash)
    </pre>
  </blockquote>
  <pre wrap=3D""><!---->Try with "nohide" option ?

Vincent


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
<a class=3D"moz-txt-link-freetext" href=3D"http://sel.as-us.falkag.net/se=
l?cmd=3Dk&kid=110944&bid$1720&dat=121642">http://sel.as-us.falkag.net/sel=
?cmd=3Dk&amp;kid=110944&amp;bid$1720&amp;dat=121642</a>
_______________________________________________
NFS maillist  -  <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:NFS=
@lists.sourceforge.net">NFS@lists.sourceforge.net</a>
<a class=3D"moz-txt-link-freetext" href=3D"https://lists.sourceforge.net/=
lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a>
  </pre>
</blockquote>
<br>
</body>
</html>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
