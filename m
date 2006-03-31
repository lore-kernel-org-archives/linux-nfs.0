From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 230GB partition mount problem
Date: Fri, 31 Mar 2006 07:44:16 -0500
Message-ID: <1143809056.8096.6.camel@lade.trondhjem.org>
References: <442CECE7.1040806@beriltech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPJ0V-00033Y-9V
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 04:45:39 -0800
Received: from pat.uio.no ([129.240.10.6])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FPJ0Q-0005S7-Qw
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 04:45:39 -0800
To: Genco YILMAZ <gyilmaz@beriltech.com>
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

On Fri, 2006-03-31 at 11:48 +0300, Genco YILMAZ wrote:
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
> noauto,nolock,nosuid,noexec,rw,hard,intr,rsize=1024,wsize=1024 0 0
> Server parameters exportfs: (rw,sync,no_subtree_check,no_root_squash)
> 
> I dont understand why one partition is reachable but the other one is 
> not. I have search in FAQ whether there is any inode limitations or not 
> but I havent seen any clue.

'man 5 exports'

Read all about the 'nohide' option, and then apply it to the export
options for the directories that you do not want to be hidden.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
