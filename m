From: Vincent Roqueta <vincent.roqueta@bull.net>
Subject: Re: 230GB partition mount problem
Date: Fri, 31 Mar 2006 10:57:21 +0200
Message-ID: <200603311057.21433.vincent.roqueta@bull.net>
References: <442CECE7.1040806@beriltech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-9"
Cc: Genco YILMAZ <gyilmaz@beriltech.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPFOo-0003XQ-18
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 00:54:30 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPFOm-0007Nm-JK
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 00:54:30 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <442CECE7.1040806@beriltech.com>
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

Le Vendredi 31 Mars 2006 10:48, Genco YILMAZ a =E9crit=A0:
> Hello,
>    I have mounted a partition from NFS server. The partitions on the
> server is
>
> /var/images/apachelogs
> /var/images/www/uploads
>
> /var/images is a directory on the / filesystem
> apachelogs(ext3) is a 230GB partition with block size 1024KB and inode
> count 30519296
> uploads is a reiserfs file system.
>
> My problem is :
>        I mount /var/images directory to the client machine through NFS
> server and I can see uploads folder but even if I have given all the
> permissions on the source folder I cannot see any subdirectory in the
> apachelogs folder as if there is nothing in it.
>
> My mount options:
> noauto,nolock,nosuid,noexec,rw,hard,intr,rsize=3D1024,wsize=3D1024 0 0
> Server parameters exportfs: (rw,sync,no_subtree_check,no_root_squash)
Try with "nohide" option ?

Vincent


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
