From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: nfsd & nfs modules : insert error
Date: Wed, 25 Feb 2004 10:25:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402251025.35974.vincent.roqueta@ext.bull.net>
References: <200402231401.12339.vincent.roqueta@ext.bull.net> <20040223182331.GA5074@fieldses.org>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvvGi-00077Y-9R
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 01:23:52 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvvFX-0001ZT-Qx
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 01:22:40 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id KAA15410
	for <nfs@lists.sourceforge.net>; Wed, 25 Feb 2004 10:23:21 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20040223182331.GA5074@fieldses.org>
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


> It's possible.  I've tested with 2.6.3-CITI_NFS4_ALL-2 (server and
> client) and I'm not able to reproduce the problem you report either with
> vi or with a c program that similarly tries open's on nonexistant files.
>
> --Bruce Fields


modprobe fail for nfs & nfsd
client and server linux 2.6.3-CITI_NFS4_ALL-2

process `named' is using obsolete setsockopt SO_BSDCOMPAT
nfsd: Unknown symbol nfs4_acl_nfsv4_to_posix
nfsd: Unknown symbol locks_remove_posix
nfsd: Unknown symbol nfs4_acl_posix_to_nfsv4

same errors when inserting nfs.ko ...

make modules_install (server)
if [ -r System.map ]; then /sbin/depmod -ae -F System.map  
2.6.3-CITI_NFS4_ALL-2; fi
WARNING: /lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/fs/nfsd/nfsd.ko needs 
unknown symbol nfs4_acl_nfsv4_to_posix
WARNING: /lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/fs/nfsd/nfsd.ko needs 
unknown symbol locks_remove_posix
WARNING: /lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/fs/nfsd/nfsd.ko needs 
unknown symbol nfs4_acl_posix_to_nfsv4

Quite same for client:


if [ -r System.map ]; then /sbin/depmod -ae -F System.map  
2.6.3-CITI_NFS4_ALL-2; fi
WARNING: /lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/fs/nfs/nfs.ko needs unknown 
symbol nfs4_acl_nfsv4_to_posix
WARNING: /lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/fs/nfs/nfs.ko needs unknown 
symbol nfs4_acl_posix_to_nfsv4
WARNING: 
/lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/net/sunrpc/auth_gss/auth_rpcgss.ko 
needs unknown symbol read_bytes_from_xdr_buf
WARNING: 
/lib/modules/2.6.3-CITI_NFS4_ALL-2/kernel/net/sunrpc/auth_gss/auth_rpcgss.ko 
needs unknown symbol read_u32_from_xdr_buf




I'm trying
- with a builtin nfs and nfsd
- to correct that...




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
