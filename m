From: "Andrew Gray" <7114@blargh.com>
Subject: Patch to mountd to mount files > 2GB
Date: Tue, 13 Jan 2004 21:19:16 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01c401c3da5d$f50dc580$2a00a8c0@phoenix>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_01C1_01C3DA1A.E62560C0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AgdR5-0000pA-EP
	for nfs@lists.sourceforge.net; Tue, 13 Jan 2004 21:19:23 -0800
Received: from wsip-24-234-142-86.lv.lv.cox.net ([24.234.142.86] helo=blargh.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1AgdR4-0005A5-RL
	for nfs@lists.sourceforge.net; Tue, 13 Jan 2004 21:19:23 -0800
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

This is a multi-part message in MIME format.

------=_NextPart_000_01C1_01C3DA1A.E62560C0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Greetings all,

If this has been problem/solution has been posted before, please =
disregard
:)

I'm using NFS to serve out FLAR archives to Sun machines.  These files =
are >
2GB, and the auto-installer for the Sun boxes mount the files, not the
directories.  mountd was refusing to authenticate these otherwise legit
requests because the stat() call was bombing due the filesize being too
large.  I hacked up the quick diff below that fixed the problem.  The =
files
transfer correctly and completely, but I admit I haven't performed =
further
testing.

diff -u nfs-utils-1.0.6-orig/utils/mountd/mountd.c
nfs-utils-1.0.6/utils/mountd/mountd.c
--- nfs-utils-1.0.6-orig/utils/mountd/mountd.c  Fri Sep 12 15:14:16 2003
+++ nfs-utils-1.0.6/utils/mountd/mountd.c       Tue Jan 13 20:11:49 2004
@@ -176,7 +176,7 @@
 {
        struct sockaddr_in *sin
                =3D (struct sockaddr_in *) =
svc_getcaller(rqstp->rq_xprt);
-       struct stat     stb;
+       struct stat64   stb;
        nfs_export      *exp;
        char            rpath[MAXPATHLEN+1];
        char            *p =3D *path;
@@ -198,7 +198,7 @@
        /* Now authenticate the intruder... */
        if (!(exp =3D auth_authenticate("pathconf", sin, p))) {
                return 1;
-       } else if (stat(p, &stb) < 0) {
+       } else if (stat64(p, &stb) < 0) {
                xlog(L_WARNING, "can't stat exported dir %s: %s",
                                p, strerror(errno));
                export_reset (exp);
@@ -248,7 +248,7 @@
 {
        struct sockaddr_in *sin =3D
                (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-       struct stat     stb, estb;
+       struct stat64   stb, estb;
        nfs_export      *exp;
        char            rpath[MAXPATHLEN+1];
        char            *p =3D *path;
@@ -268,7 +268,7 @@
        /* Now authenticate the intruder... */
        if (!(exp =3D auth_authenticate("mount", sin, p))) {
                *error =3D NFSERR_ACCES;
-       } else if (stat(p, &stb) < 0) {
+       } else if (stat64(p, &stb) < 0) {
                xlog(L_WARNING, "can't stat exported dir %s: %s",
                                p, strerror(errno));
                if (errno =3D=3D ENOENT)
@@ -278,7 +278,7 @@
        } else if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
                xlog(L_WARNING, "%s is not a directory or regular file", =
p);
                *error =3D NFSERR_NOTDIR;
-       } else if (stat(exp->m_export.e_path, &estb) < 0) {
+       } else if (stat64(exp->m_export.e_path, &estb) < 0) {
                xlog(L_WARNING, "can't stat export point %s: %s",
                     p, strerror(errno));
                *error =3D NFSERR_NOENT;


------=_NextPart_000_01C1_01C3DA1A.E62560C0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1276" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>Greetings all,<BR><BR>If this has been =
problem/solution=20
has been posted before, please disregard<BR>:)<BR><BR>I'm using NFS to =
serve out=20
FLAR archives to Sun machines.&nbsp; These files are &gt;<BR>2GB, and =
the=20
auto-installer for the Sun boxes mount the files, not =
the<BR>directories.&nbsp;=20
mountd was refusing to authenticate these otherwise legit<BR>requests =
because=20
the stat() call was bombing due the filesize being too<BR>large.&nbsp; I =
hacked=20
up the quick diff below that fixed the problem.&nbsp; The =
files<BR>transfer=20
correctly and completely, but I admit I haven't performed=20
further<BR>testing.<BR><BR>diff -u=20
nfs-utils-1.0.6-orig/utils/mountd/mountd.c<BR>nfs-utils-1.0.6/utils/mount=
d/mountd.c<BR>---=20
nfs-utils-1.0.6-orig/utils/mountd/mountd.c&nbsp; Fri Sep 12 15:14:16 =
2003<BR>+++=20
nfs-utils-1.0.6/utils/mountd/mountd.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 Tue=20
Jan 13 20:11:49 2004<BR>@@ -176,7 +176,7=20
@@<BR>&nbsp;{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct =
sockaddr_in=20
*sin<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;=20
=3D (struct sockaddr_in *)=20
svc_getcaller(rqstp-&gt;rq_xprt);<BR>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;=20
struct stat&nbsp;&nbsp;&nbsp;&nbsp;=20
stb;<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct stat64&nbsp;&nbsp;=20
stb;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
nfs_export&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
*exp;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
char&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rpath[MAXPATHLEN+1];<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
char&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
*p =3D=20
*path;<BR>@@ -198,7 +198,7 =
@@<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /*=20
Now authenticate the intruder...=20
*/<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!(exp =3D=20
auth_authenticate("pathconf", sin, p)))=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
return 1;<BR>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } else if (stat(p, =
&amp;stb)=20
&lt; 0) {<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } else if (stat64(p,=20
&amp;stb) &lt; 0)=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
xlog(L_WARNING, "can't stat exported dir %s:=20
%s",<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
p,=20
strerror(errno));<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
export_reset (exp);<BR>@@ -248,7 +248,7=20
@@<BR>&nbsp;{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct =
sockaddr_in=20
*sin=20
=3D<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;=20
(struct sockaddr_in *)=20
svc_getcaller(rqstp-&gt;rq_xprt);<BR>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;=20
struct stat&nbsp;&nbsp;&nbsp;&nbsp; stb,=20
estb;<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct stat64&nbsp;&nbsp; =
stb,=20
estb;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
nfs_export&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
*exp;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
char&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
rpath[MAXPATHLEN+1];<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
char&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
*p =3D=20
*path;<BR>@@ -268,7 +268,7 =
@@<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /*=20
Now authenticate the intruder...=20
*/<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!(exp =3D=20
auth_authenticate("mount", sin, p)))=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
*error =3D NFSERR_ACCES;<BR>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } else =
if=20
(stat(p, &amp;stb) &lt; 0) {<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } =
else if=20
(stat64(p, &amp;stb) &lt; 0)=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
xlog(L_WARNING, "can't stat exported dir %s:=20
%s",<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
p,=20
strerror(errno));<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
if (errno =3D=3D ENOENT)<BR>@@ -278,7 +278,7=20
@@<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } else if=20
(!S_ISDIR(stb.st_mode) &amp;&amp; !S_ISREG(stb.st_mode))=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
xlog(L_WARNING, "%s is not a directory or regular file",=20
p);<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;=20
*error =3D NFSERR_NOTDIR;<BR>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } =
else if=20
(stat(exp-&gt;m_export.e_path, &amp;estb) &lt; 0)=20
{<BR>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; } else if=20
(stat64(exp-&gt;m_export.e_path, &amp;estb) &lt; 0)=20
{<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;=20
xlog(L_WARNING, "can't stat export point %s:=20
%s",<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
p,=20
strerror(errno));<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
*error =3D NFSERR_NOENT;<BR>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_01C1_01C3DA1A.E62560C0--



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
