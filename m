From: "Corporal Pisang" <Corporal_Pisang@Counter-Strike.com.my>
Subject: nfs compile error on 2.5.45
Date: Thu, 31 Oct 2002 13:14:59 +0800 (MYT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <34819.10.2.16.178.1036041299.squirrel@mail.Vault-ID.com>
Reply-To: Corporal_Pisang@Counter-Strike.com.my
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [210.19.28.13] (helo=gateway.vault-id.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1877iR-0001td-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 21:17:59 -0800
To: <nfs@lists.sourceforge.net>
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

Hi , I get this error compiling nfsd on 2.5.45.

gcc -Wp,-MD,fs/nfsd/.nfs4proc.o.d -D__KERNEL__ -Iinclude -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fomit-frame-pointer
-fno-strict-aliasing -fno-common -pipe -mpreferred-stack-boundary=2
-march=athlon -Iarch/i386/mach-generic -nostdinc -iwithprefix include   
-DKBUILD_BASENAME=nfs4proc   -c -o fs/nfsd/nfs4proc.o fs/nfsd/nfs4proc.c
fs/nfsd/nfs4proc.c: In function `nfsd4_write':
fs/nfsd/nfs4proc.c:484: warning: passing arg 4 of `nfsd_write' from
incompatible pointer type
fs/nfsd/nfs4proc.c:484: warning: passing arg 6 of `nfsd_write' makes
integer from pointer without a cast
fs/nfsd/nfs4proc.c:484: too few arguments to function `nfsd_write'
fs/nfsd/nfs4proc.c: In function `nfsd4_proc_compound':
fs/nfsd/nfs4proc.c:568: structure has no member named `rq_resbuf'
fs/nfsd/nfs4proc.c:569: structure has no member named `rq_resbuf'
fs/nfsd/nfs4proc.c:569: structure has no member named `rq_resbuf'
make[2]: *** [fs/nfsd/nfs4proc.o] Error 1
make[1]: *** [fs/nfsd] Error 2
make: *** [fs] Error 2

Regards,

-Ubaida-




-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
