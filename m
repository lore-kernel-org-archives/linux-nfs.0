From: haichuang xing <foxgoblin@gmail.com>
Subject: the kernel 2.4 can not mount kernel 2.6 nfs exports.
Date: Thu, 31 Mar 2005 14:31:54 +0800
Message-ID: <a61da3d7050330223172e55fef@mail.gmail.com>
References: <a61da3d70503301814a08aa5d@mail.gmail.com>
Reply-To: haichuang xing <foxgoblin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGtDh-0004Cj-AY
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 22:31:57 -0800
Received: from rproxy.gmail.com ([64.233.170.193])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DGtDf-0000Dg-Uv
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 22:31:57 -0800
Received: by rproxy.gmail.com with SMTP id f1so274471rne
        for <nfs@lists.sourceforge.net>; Wed, 30 Mar 2005 22:31:55 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: <a61da3d70503301814a08aa5d@mail.gmail.com>
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

in kernel 2.6 server:
/etc/exports:
/home/webadm/htdocs *(ro,all_squash)

in kernel 2.4 server:
#mount -t nfs -o ro nfsserver:/home/webadm/htdocs /mnt/nfs

i get:
mount: wrong fs type, bad option, bad superblock on
nfsserver:/home/webadm/htdocs, or too many mounted file systems

use strace:

strace mount -t nfs -o ro nfsserver:/home/webadm/htdocs /mnt/nfs

i found:

mount("nfsserver:/home/webadm/htdocs", "/mnt/nfs", "nfs",
MS_RDONLY|0xc0ed0000, 0x80598e0) = -1 EINVAL (Invalid argument)

why?

sorry for my poor english.


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
