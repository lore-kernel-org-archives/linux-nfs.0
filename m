From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: broken umount -f
Date: Wed, 15 Jan 2003 06:45:49 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D551F9@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Yonk-0001Yq-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 06:45:56 -0800
To: "'Scott Mcdermott'" <smcdermott@questra.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> To nfs@lists.sourceforge.net on Wed 15/01 00:19 -0500:
> > Lever, Charles on Tue 14/01 11:36 -0800:
> > <on client>
> 
> forgot to include
> 
> # grep nfsserver /proc/mounts
> nfsserver:/tmp /mnt/tmp nfs 
> rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=nfsserver 0 0

thanks!

what if you try it again with the intr mount option?

if that doesn't help, enable rpc level debugging and send me
the kernel log contents.

echo  3 > /proc/sys/sunrpc/rpc_debug   #  to enable debugging
echo  0 > /proc/sys/sunrpc/rpc_debug   #  to turn it off again


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
