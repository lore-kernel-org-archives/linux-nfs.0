From: <eddymulyono@dslextreme.com>
Subject: mount.x
Date: Fri, 27 Jun 2003 21:31:15 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32796.66.159.224.134.1056774675.squirrel@www.dslextreme.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp.dslextreme.com ([66.51.205.17] helo=co1.dslextreme.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19W7Rs-0006xN-00
	for <nfs@lists.sourceforge.net>; Fri, 27 Jun 2003 21:36:28 -0700
Received: from dslextreme.com (www [192.168.7.16])
	by co1.dslextreme.com (8.12.9/8.12.6) with SMTP id h5S4VFor010021
	for <nfs@lists.sourceforge.net>; Fri, 27 Jun 2003 21:31:15 -0700
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

I'm having trouble compiling nfs-utils 1.0.3. After I issued
[$./configure], [$make] spitted these important errors :

gcc -g -O2 -D_GNU_SOURCE -I../../support/include -Wall  -pipe 
-DVERSION="\"nfs-utils 1.0.3\"" -DNFS3_SUPPORTED   -c -o mountd.o mountd.c
In file included from mountd.c:24:
mountd.h:19: parse error before "dirpath"
mountd.h:19: warning: no semicolon at end of struct or union

After hunting around, I think it is caused by the following lines in
support/export/mount.x:64:

union fhstatus switch (unsigned fhs_status) {
case 0:
	fhandle fhs_fhandle;
default:
	void;
};

I looked around the mailing list and the CVS, and found out that mount.x
is aged at 3 years. I've attended several C classes, and I don't think the
code excerpt above is gramatically correct. I think it caused GCC to panic
and messes the rest of the compilation.

But I might be wrong. Maybe it is a C trick. Can anyone shed light on this
issue?

The complete [$make] errors are enclosed.

In the meanwhile, I'll just go lazy and use the RPMs from my Mandrake 9.0.
 :p

Thanx,

-Eddy

gcc -g -O2 -D_GNU_SOURCE -I../../support/include -Wall  -pipe 
-DVERSION="\"nfs-utils 1.0.3\"" -DNFS3_SUPPORTED   -c -o mountd.o mountd.c
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
mountd.h:51: warning: type defaults to `int' in declaration of
`mountlist_list'
mountd.h:51: warning: data definition has no type or storage class
mountd.c:28: parse error before "get_exportlist"
mountd.c:28: warning: type defaults to `int' in declaration of
`get_exportlist'
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





-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
