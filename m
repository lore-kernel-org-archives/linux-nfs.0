From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: [PATCH] nfsstat.man
Date: Mon, 11 Apr 2005 10:55:44 -0400
Message-ID: <20050411145544.GA23506@gam3.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DL0Kj-0008Dm-QV
	for nfs@lists.sourceforge.net; Mon, 11 Apr 2005 07:56:13 -0700
Received: from mta9.adelphia.net ([68.168.78.199])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DL0Kh-00082e-Nn
	for nfs@lists.sourceforge.net; Mon, 11 Apr 2005 07:56:13 -0700
Received: from harpo.ny.gam3.net ([68.235.28.141]) by mta9.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050411145549.ZFHX2192.mta9.adelphia.net@harpo.ny.gam3.net>
          for <nfs@lists.sourceforge.net>; Mon, 11 Apr 2005 10:55:49 -0400
Received: from gam3 by harpo.ny.gam3.net with local (Exim 3.36 #1 (Debian))
	id 1DL0KG-00068p-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Apr 2005 10:55:44 -0400
To: nfs@lists.sourceforge.net
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


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Could I have comments this patch.

I should have a patch for nfsstat to have it match the man file with in
the next day or so.

I have included the complete new man page as well as a patch against
CVS.

Allen Morris


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfsstat.man.patch"

Index: nfsstat.man
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/nfsstat/nfsstat.man,v
retrieving revision 1.2
diff -u -r1.2 nfsstat.man
--- nfsstat.man	7 Oct 2001 06:24:35 -0000	1.2
+++ nfsstat.man	11 Apr 2005 14:52:40 -0000
@@ -1,30 +1,46 @@
 .\"
 .\" nfsstat(8)
 .\" 
-.\" Copyright (C) 1996 Olaf Kirch <okir@monad.swb.de>
-.TH nfsstat 8 "05 Oct 2001"
+.\" Copyright (C) 1996-2005 Olaf Kirch <okir@monad.swb.de>
+.TH nfsstat 8 "11 Apr 2005"
 .SH NAME
-nfsstat \- print NFS statistics
+nfsstat \- list NFS statistics
 .SH SYNOPSIS
-.BI "/usr/sbin/nfsstat [-anrcsz] [-o " "facility" "] ...
+.B nfsstat
+[\fIOPTION\fR]...
 .SH DESCRIPTION
 The
 .B nfsstat
 displays statistics kept about NFS client and server activity.
 .SH OPTIONS
 .TP
-.B -s
+.B -s, --server
 Print only server-side statistics. The default is to print both server and
 client statistics.
 .TP
-.B -c
+.B -c, --client
 Print only client-side statistics.
 .TP
-.B -n
+.B -n, --nfs
 Print only NFS statistics. The default is to print both NFS and RPC
 information.
 .TP
-.B -r
+.B -2
+Print only NFS v2 statistics. The default is to only print information
+about the versions of \fBNFS\fR that have non-zero counts.
+.TP
+.B -3
+Print only NFS v3 statistics. 
+.TP
+.B -4
+Print only NFS v4 statistics. 
+.TP
+.B -m, --mounted
+Print information about each of the mounted \fBNFS\fR file systems.
+
+If this option is used, all other options are ignored.
+.TP
+.B -r, --rpc
 Print only RPC statistics.
 .TP
 .BI -o " facility
@@ -48,8 +64,35 @@
 .B rc
 Usage information on the server's request reply cache, including the
 total number of lookups, and the number of hits and misses.
+.TP
+.B all
+Display all of the above facilities.
 .RE
+.TP
+.B -v, --verbose
+This is equivient to \fB-o all\fR.
 .SH EXAMPLES
+.TP
+.B nfsstat -o all -234
+Show all information about all versions of \fBNFS\fR.
+.TP
+.B nfsstat --verbose -234
+Same as above.
+.TP
+.B nfsstat -o all
+Show all information about about active versions of \fBNFS\fR.
+.TP
+.B nfsstat --nfs --server -3
+Show statictics for \fBNFS\fR version 3 server.
+.TP
+.B nfsstat -m
+Show information about mounted \fBNFS\fR filesystems.
+.\" --------------------- DISPLAY --------------------------------
+.SH DISPLAY
+.TP
+The \fBFlags\fR output from the \fB-m\fR option is the same as the
+flags give to the \fBmount\fR command.
+.TP
 .\" --------------------- FILES ----------------------------------
 .SH FILES
 .TP
@@ -60,9 +103,22 @@
 .B /proc/net/rpc/nfs
 .BR procfs -based
 interface to kernel NFS client statistics.
+.TP
+.B /proc/mounts
+.BR procfs -based
+interface to the mounted filesystems.
 .\" -------------------- SEE ALSO --------------------------------
 .SH SEE ALSO
 .BR rpc.nfsd (8).
+.BR nfs (5).
+.SH BUGS
+.TP
+The \fBDisplay\fR section should be more commplete.
+.TP
+The function of the \fB-v\fR and \fB-a\fR options have changed.
+.TP
+Further bugs can be found or reported at 
+.BR http://nfs.sf.net/ .
 .\" -------------------- AUTHOR ----------------------------------
 .SH AUTHOR
 Olaf Kirch, <okir@monad.swb.de>

--Q68bSM7Ycu6FN28Q
Content-Type: application/x-troff-man
Content-Disposition: attachment; filename="nfsstat.man"
Content-Transfer-Encoding: quoted-printable

=2E\"=0A.\" nfsstat(8)=0A.\" =0A.\" Copyright (C) 1996-2005 Olaf Kirch <oki=
r@monad.swb.de>=0A.TH nfsstat 8 "11 Apr 2005"=0A.SH NAME=0Anfsstat \- list =
NFS statistics=0A.SH SYNOPSIS=0A.B nfsstat=0A[\fIOPTION\fR]...=0A.SH DESCRI=
PTION=0AThe=0A.B nfsstat=0Adisplays statistics kept about NFS client and se=
rver activity.=0A.SH OPTIONS=0A.TP=0A.B -s, --server=0APrint only server-si=
de statistics. The default is to print both server and=0Aclient statistics.=
=0A.TP=0A.B -c, --client=0APrint only client-side statistics.=0A.TP=0A.B -n=
, --nfs=0APrint only NFS statistics. The default is to print both NFS and R=
PC=0Ainformation.=0A.TP=0A.B -2=0APrint only NFS v2 statistics. The default=
 is to only print information=0Aabout the versions of \fBNFS\fR that have n=
on-zero counts.=0A.TP=0A.B -3=0APrint only NFS v3 statistics. =0A.TP=0A.B -=
4=0APrint only NFS v4 statistics. =0A.TP=0A.B -m, --mounted=0APrint informa=
tion about each of the mounted \fBNFS\fR file systems.=0A=0AIf this option =
is used, all other options are ignored.=0A.TP=0A.B -r, --rpc=0APrint only R=
PC statistics.=0A.TP=0A.BI -o " facility=0ADisplay statistics for the speci=
fied facility, which must be one of:=0A.RS=0A.TP=0A.B nfs=0ANFS protocol in=
formation, split up by RPC call.=0A.TP=0A.B rpc=0AGeneral RPC information.=
=0A.TP=0A.B net=0ANetwork layer statistics, such as the number of received =
packets, number=0Aof TCP connections, etc.=0A.TP=0A.B fh=0AUsage informatio=
n on the server's file handle cache, including the=0Atotal number of lookup=
s, and the number of hits and misses.=0A.TP=0A.B rc=0AUsage information on =
the server's request reply cache, including the=0Atotal number of lookups, =
and the number of hits and misses.=0A.TP=0A.B all=0ADisplay all of the abov=
e facilities.=0A.RE=0A.TP=0A.B -v, --verbose=0AThis is equivient to \fB-o a=
ll\fR.=0A.SH EXAMPLES=0A.TP=0A.B nfsstat -o all -234=0AShow all information=
 about all versions of \fBNFS\fR.=0A.TP=0A.B nfsstat --verbose -234=0ASame =
as above.=0A.TP=0A.B nfsstat -o all=0AShow all information about about acti=
ve versions of \fBNFS\fR.=0A.TP=0A.B nfsstat --nfs --server -3=0AShow stati=
ctics for \fBNFS\fR version 3 server.=0A.TP=0A.B nfsstat -m=0AShow informat=
ion about mounted \fBNFS\fR filesystems.=0A.\" --------------------- DISPLA=
Y --------------------------------=0A.SH DISPLAY=0A.TP=0AThe \fBFlags\fR ou=
tput from the \fB-m\fR option is the same as the=0Aflags give to the \fBmou=
nt\fR command.=0A.TP=0A.\" --------------------- FILES --------------------=
--------------=0A.SH FILES=0A.TP=0A.B /proc/net/rpc/nfsd=0A.BR procfs -base=
d=0Ainterface to kernel NFS server statistics.=0A.TP=0A.B /proc/net/rpc/nfs=
=0A.BR procfs -based=0Ainterface to kernel NFS client statistics.=0A.TP=0A.=
B /proc/mounts=0A.BR procfs -based=0Ainterface to the mounted filesystems.=
=0A.\" -------------------- SEE ALSO --------------------------------=0A.SH=
 SEE ALSO=0A.BR rpc.nfsd (8).=0A.BR nfs (5).=0A.SH BUGS=0A.TP=0AThe \fBDisp=
lay\fR section should be more commplete.=0A.TP=0AThe function of the \fB-v\=
fR and \fB-a\fR options have changed.=0A.TP=0AFurther bugs can be found or =
reported at =0A.BR http://nfs.sf.net/ .=0A.\" -------------------- AUTHOR -=
---------------------------------=0A.SH AUTHOR=0AOlaf Kirch, <okir@monad.sw=
b.de>=0A
--Q68bSM7Ycu6FN28Q--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
