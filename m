From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs v4 exports
Date: Wed, 18 May 2005 21:30:50 -0400
Message-ID: <1116466250.11340.8.camel@lade.trondhjem.org>
References: <200505190314.22576.rauchwolke@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYZse-0003Q9-Ij
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 18:31:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYZsc-00082S-Rt
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 18:31:20 -0700
To: Rauch Wolke <rauchwolke@gmx.net>
In-Reply-To: <200505190314.22576.rauchwolke@gmx.net>
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

to den 19.05.2005 Klokka 03:14 (+0200) skreiv Rauch Wolke:
> hello,
> 
> i use gentoo linux and i exported this directories
> 
> root@Server puchu # exportfs -v
> /home/puchu     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
> /mnt/backup     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
> 
> 
> but when i do (a on the client)
> 
> mount -t nfs4 server:/ /mnt/server
> 
> i can only see the content of /home/puchu....

What did you expect to see?

Firstly, you can only have one directory with fsid=0.
Secondly, you can only export a single directory tree.
Lastly, you have to export mount points that you want to allow the
client to cross using the "nohide" option.

IOW: if you do something like

mkdir /home/puchu/backup
mount --bind /mnt/backup /home/puchu/backup

and then set /etc/exports to

/home/puchu     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
/home/puchu/backup     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,nohide,fsid=1)

then your client will see both directories...

> with wrong group and owner ...think its the nobody user...explained in man 
> exports...but the gid and guid is the same on the client and on the server 
> for  all files 

You also need to set up idmapd on both client and server.  See for
instance
  http://www.vanemery.com/Linux/NFSv4/NFSv4-no-rpcsec.html

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
