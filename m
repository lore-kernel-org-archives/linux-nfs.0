From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Bug: sunrpc
Date: Wed, 28 Jan 2004 09:56:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401280956.31260.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AllUJ-0008Bx-Pp
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 00:55:55 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AllUI-0002aA-Js
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 00:55:54 -0800
Received: from roquetav.frec.bull.fr (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id JAA29136
	for <nfs@lists.sourceforge.net>; Wed, 28 Jan 2004 09:56:20 +0100
To: nfs@lists.sourceforge.net
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

kernel : 2.6.1
patch : 
http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/kernel-patches-2.6.1-1/linux-2.6.1-CITI_NFS4_ALL.patch

-> Compilation: really hard to compil, many problems with ACL

kernel config: 

# Network File Systems
#
# CONFIG_NFS_FS is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_V4_ACL=y
CONFIG_EXPORTFS=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=m

(I can't compil if SUNRPC_GSS and RPCSEC_GSS_KRB5 are buit-in)

modprobe:
modprobe auth_rpcgss         OK
modprobe rpcsec_gss_krb5  OK

mount --bind /home/tests /export/tests OK
exportfs -i -ofsid=0 *:/export -> bug



Jan 27 20:40:01 fastreboot kernel: kmem_cache_create: duplicate cache 
rpc_inode_cache
Jan 27 20:40:01 fastreboot kernel: ------------[ cut here ]------------
Jan 27 20:40:01 fastreboot kernel: kernel BUG at mm/slab.c:1269!
Jan 27 20:40:01 fastreboot kernel: invalid operand: 0000 [#1]
Jan 27 20:40:01 fastreboot kernel: CPU:    0
Jan 27 20:40:01 fastreboot kernel: EIP:    0060:[<c0141b77>]    Not tainted
Jan 27 20:40:01 fastreboot kernel: EFLAGS: 00010202
Jan 27 20:40:01 fastreboot kernel: EIP is at kmem_cache_create+0x447/0x530
Jan 27 20:40:01 fastreboot kernel: eax: 00000033   ebx: f7df0878   ecx: 
c043a96c   edx: c0371bdc
Jan 27 20:40:01 fastreboot kernel: esi: c0357b21   edi: f89ba988   ebp: 
f7df0614   esp: f7257f4c
Jan 27 20:40:01 fastreboot kernel: ds: 007b   es: 007b   ss: 0068
Jan 27 20:40:01 fastreboot kernel: Process modprobe (pid: 933, 
threadinfo=f7256000 task=f7318710)
Jan 27 20:40:01 fastreboot kernel: Stack: c032d300 f89ba978 00022000 f7257f68 
f7df0654 c0000000 ffffffe0 000000c0
Jan 27 20:40:01 fastreboot kernel:        c03731b0 c0373194 f89c9240 f7256000 
f89b9417 f89ba978 000001e0 00000020
Jan 27 20:40:01 fastreboot kernel:        00022000 f89b9300 00000000 f890e00c 
c0373194 c03731b0 c0138467 c043a884
Jan 27 20:40:01 fastreboot kernel: Call Trace:
Jan 27 20:40:01 fastreboot kernel:  [<f89b9417>] register_rpc_pipefs+0x37/0x60 
[sunrpc]
Jan 27 20:40:01 fastreboot kernel:  [<f89b9300>] init_once+0x0/0xe0 [sunrpc]
Jan 27 20:40:01 fastreboot kernel:  [<f890e00c>] init_sunrpc+0xc/0x54 [sunrpc]
Jan 27 20:40:01 fastreboot kernel:  [<c0138467>] sys_init_module+0x127/0x230
Jan 27 20:40:01 fastreboot kernel:  [<c010922d>] sysenter_past_esp+0x52/0x71
Jan 27 20:40:01 fastreboot kernel:
Jan 27 20:40:01 fastreboot kernel: Code: 0f 0b f5 04 df ca 32 c0 8b 0b e9 74 
ff ff ff 8b 47 38 c7 04



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
