From: trmcneal@attbi.com
Subject: nfs-utils (fwd)
Date: Thu, 20 Mar 2003 16:18:16 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18w2kM-000629-00@sc8-sf-list1.sourceforge.net>
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18w2kM-000629-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 08:18:26 -0800
To: volrath@sbcglobal.net 
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

The NFS Mailing list is the best place to get the fastest answer.  I'll
look at it in the meantime.

Tom

--
Tom McNeal
(650)906-0761(cell)
(650)964-8459(fax)
----------------------  Forwarded Message:  ---------------------
From:    Michael Butler <volrath@sbcglobal.net>
To:      trmcneal@attbi.com
Subject: nfs-utils
Date:    Wed, 19 Mar 2003 17:22:12 -0800

I am having some problems, and I thought that maybe you could enlighten 
me.  I am attempting to compile nfs-utils with gcc 3.2 running linux 
2.4.20 with nfs, nfsv3, etc enabled in the kernel.  It doesn't seem to 
like the unions in mountd at all.  Attached is a copy of the compile 
error.

Hope you can help.

Making all in mountd
gcc -g -O2 -D_GNU_SOURCE -I../../support/include -Wall  -pipe  
-DVERSION="\"nfs-utils 1.0.1\"" -DNFS3_SUPPORTED   -c -o mountd.o mountd.c
In file included from mountd.c:24:
mountd.h:19: parse error before "dirpath"
mountd.h:19: warning: no semicolon at end of struct or union
mountd.h:23: parse error before "fhstatus"
mountd.h:23: warning: no semicolon at end of struct or union
mountd.h:24: warning: type defaults to `int' in declaration of `mountlist'
mountd.h:24: warning: data definition has no type or storage class
mountd.h:25: parse error before "exports"
mountd.h:25: warning: type defaults to `int' in declaration of `exports'
mountd.h:25: warning: data definition has no type or storage class
mountd.h:32: parse error before "dirpath"
mountd.h:33: parse error before "mountlist"
mountd.h:34: parse error before "dirpath"
mountd.h:36: parse error before "exports"
mountd.h:37: parse error before "exports"
mountd.h:38: parse error before "dirpath"
mountd.h:39: parse error before "dirpath"
mountd.h:51: parse error before "mountlist_list"
mountd.h:51: warning: type defaults to `int' in declaration of `mountlist_list'
mountd.h:51: warning: data definition has no type or storage class
mountd.c:28: parse error before "get_exportlist"
mountd.c:28: warning: type defaults to `int' in declaration of `get_exportlist'
mountd.c:28: warning: data definition has no type or storage class
mountd.c:29: parse error before "dirpath"
mountd.c: In function `killer':
mountd.c:55: `MOUNTPROG' undeclared (first use in this function)
mountd.c:55: (Each undeclared identifier is reported only once
mountd.c:55: for each function it appears in.)
mountd.c:55: `MOUNTVERS' undeclared (first use in this function)
mountd.c:57: `MOUNTVERS_POSIX' undeclared (first use in this function)
mountd.c:59: `MOUNTVERS_NFSV3' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:70: parse error before "dirpath"
mountd.c: In function `mount_mnt_1_svc':
mountd.c:74: `path' undeclared (first use in this function)
mountd.c:75: `rqstp' undeclared (first use in this function)
mountd.c:75: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:81: parse error before "mountlist"
mountd.c: In function `mount_dump_1_svc':
mountd.c:84: `rqstp' undeclared (first use in this function)
mountd.c:88: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:93: parse error before "dirpath"
mountd.c: In function `mount_umnt_1_svc':
mountd.c:96: `rqstp' undeclared (first use in this function)
mountd.c:98: `argp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:128: parse error before "exports"
mountd.c: In function `mount_export_1_svc':
mountd.c:131: `rqstp' undeclared (first use in this function)
mountd.c:134: `resp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:139: parse error before "exports"
mountd.c: In function `mount_exportall_1_svc':
mountd.c:142: `rqstp' undeclared (first use in this function)
mountd.c:145: `resp' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:161: parse error before "dirpath"
mountd.c: In function `mount_pathconf_2_svc':
mountd.c:164: `rqstp' undeclared (first use in this function)
mountd.c:168: `path' undeclared (first use in this function)
mountd.c:170: `res' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:215: parse error before "dirpath"
mountd.c: In function `mount_mnt_3_svc':
mountd.c:220: `path' undeclared (first use in this function)
mountd.c:221: `rqstp' undeclared (first use in this function)
mountd.c:221: `res' undeclared (first use in this function)
mountd.c:224: dereferencing pointer to incomplete type
mountd.c:225: dereferencing pointer to incomplete type
mountd.c:226: dereferencing pointer to incomplete type
mountd.c:227: dereferencing pointer to incomplete type
mountd.c: At top level:
mountd.c:233: parse error before "dirpath"
mountd.c: In function `get_rootfh':
mountd.c:236: `rqstp' undeclared (first use in this function)
mountd.c:240: `path' undeclared (first use in this function)
mountd.c:256: `error' undeclared (first use in this function)
mountd.c:275: `v3' undeclared (first use in this function)
mountd.c: At top level:
mountd.c:299: parse error before "get_exportlist"
mountd.c:300: warning: return type defaults to `int'
mountd.c: In function `get_exportlist':
mountd.c:301: syntax error before "elist"
mountd.c:307: `elist' undeclared (first use in this function)
mountd.c:311: dereferencing pointer to incomplete type
mountd.c:312: dereferencing pointer to incomplete type
mountd.c:313: dereferencing pointer to incomplete type
mountd.c:314: dereferencing pointer to incomplete type
mountd.c:317: dereferencing pointer to incomplete type
mountd.c:324: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:325: dereferencing pointer to incomplete type
mountd.c:329: dereferencing pointer to incomplete type
mountd.c:330: dereferencing pointer to incomplete type
mountd.c:331: dereferencing pointer to incomplete type
mountd.c:332: dereferencing pointer to incomplete type
mountd.c:338: dereferencing pointer to incomplete type
mountd.c:339: dereferencing pointer to incomplete type
mountd.c:340: dereferencing pointer to incomplete type
mountd.c:341: dereferencing pointer to incomplete type
mountd.c:344: dereferencing pointer to incomplete type
mountd.c:348: dereferencing pointer to incomplete type
mountd.c:351: dereferencing pointer to incomplete type
mountd.c:353: dereferencing pointer to incomplete type
mountd.c:354: dereferencing pointer to incomplete type
mountd.c:357: dereferencing pointer to incomplete type
mountd.c:358: dereferencing pointer to incomplete type
mountd.c:367: dereferencing pointer to incomplete type
mountd.c:372: dereferencing pointer to incomplete type
mountd.c:372: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:374: dereferencing pointer to incomplete type
mountd.c:378: dereferencing pointer to incomplete type
mountd.c:379: dereferencing pointer to incomplete type
mountd.c:380: dereferencing pointer to incomplete type
mountd.c:380: dereferencing pointer to incomplete type
mountd.c:381: dereferencing pointer to incomplete type
mountd.c: In function `main':
mountd.c:495: `MOUNTPROG' undeclared (first use in this function)
mountd.c:495: `MOUNTVERS' undeclared (first use in this function)
mountd.c:498: `MOUNTVERS_POSIX' undeclared (first use in this function)
mountd.c:501: `MOUNTVERS_NFSV3' undeclared (first use in this function)
make[2]: *** [mountd.o] Error 1
make[1]: *** [all] Error 2
make: *** [all] Error 2

Michael Butler
volrath@sbcglobal.net


-------------------------------------------------------
This SF.net email is sponsored by: Tablet PC.  
Does your code think in ink? You could win a Tablet PC. 
Get a free Tablet PC hat just for playing. What are you waiting for? 
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
