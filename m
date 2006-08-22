From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch/rfc] make ldap support in libnfsidmap optional
Date: Mon, 21 Aug 2006 22:32:13 -0400
Message-ID: <200608212232.14243.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_uym6EALRyN2D8+p"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GFM2l-0001lA-IJ
	for nfs@lists.sourceforge.net; Mon, 21 Aug 2006 19:31:07 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GFM2i-0003aq-LC
	for nfs@lists.sourceforge.net; Mon, 21 Aug 2006 19:31:08 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 6E21B647A1
	for <nfs@lists.sourceforge.net>; Tue, 22 Aug 2006 02:31:00 +0000 (UTC)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--Boundary-00=_uym6EALRyN2D8+p
Content-Type: multipart/signed; boundary="nextPart4820819.qrGHoyTo5y";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart4820819.qrGHoyTo5y
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

find attached a patch that allows libnfsidmap to be built without ldap support
-mike

--nextPart4820819.qrGHoyTo5y
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iQIVAwUAROpsrkFjO5/oN/WBAQLr3BAAheUy4svPTCwGQAEChRfwABoa+uy6/PUR
b0a4Bww1YzSeBQgKBoZfEwKJD+7mJyw/E6Uw5OoAJwvd22VUR2c0a19P+TCGXTC3
y6qki/jLL3YajvnW4XuNQveOhWC+j+i9NpQa9iPeqOYD8ekdhe8/hWl+Q6cdgMac
c41ZuCvgWLZ0ROR+hDmMjLlcwontua71uH/5SnFgpp37ta08etBTYBr5xeMSHCGd
sX1TjaKgCLRNQv2YgqlOH221blEZ8IygeN3EKIhwTBsYB4qiyT2QykebJlLghByY
Qx+qoGRJE/l1JcKCMkykjamPQob4BSfrN9vMyc8tOA54ax/mppWbcossCrXnHqr5
yxjgYbq/Aoj7WeaRlPfaKrBZumvWE3hgQ62g0t9Ff2DagKPD8RgP8OPQ+BPzHRW9
FSEuLcO+uFU7/pBJGbeqmnLydu57G/9frPGcJim8izimhsJ0CLx9CQzmCGzvM567
/WrQX1n0F4Fcy26MMWTBZ30pUXGvEJgxd3/eGCA4jtRjFSDkmvKtjkKiuAuHToPq
cW997gYgFhY5FLBc3y28Ep04nHdx6wWKIYXAF/zCR/b5R5NJQOp/0koP1w/I+HTK
y5+3/YEIbED96aUfVih4qTV/PNtUc7DYSL7yTPpeUuiVPERb3SSyRIEIdzb0UrQT
96gd9IsvbJQ=
=CIbS
-----END PGP SIGNATURE-----

--nextPart4820819.qrGHoyTo5y--

--Boundary-00=_uym6EALRyN2D8+p
Content-Type: text/x-diff; charset="us-ascii";
	name="libnfsidmap-optional-ldap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="libnfsidmap-optional-ldap.patch"

--- libnfsidmap-0.17/configure.in
+++ libnfsidmap-0.17/configure.in
@@ -13,6 +13,21 @@
 
 # Checks for libraries.
 
+AC_ARG_ENABLE([ldap],
+	[AC_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
+if test "x$enable_ldap" != "xno" ; then
+	AC_CHECK_HEADER([ldap.h],
+		[AC_CHECK_LIB([ldap], [ldap_initialize],
+		              [have_ldap="yes"],[have_ldap="no"])],
+		[have_ldap="no"])
+	if test "x$have_ldap" = "xyes" ; then
+		AC_DEFINE([ENABLE_LDAP], 1, [Enable LDAP Support])
+		LIBS="$LIBS -lldap"
+	elif test "x$enable_ldap$have_ldap" = "xyesno" ; then
+		AC_MSG_ERROR(LDAP support not found!)
+	fi
+fi
+
 # Checks for header files.
 AC_HEADER_STDC
 AC_CHECK_HEADERS([stdlib.h string.h unistd.h errno.h])
--- libnfsidmap-0.17/Makefile.am
+++ libnfsidmap-0.17/Makefile.am
@@ -4,7 +4,6 @@
 libnfsidmap_la_LDFLAGS = -version-info 2:0:2
 include_HEADERS = nfsidmap.h
 EXTRA_DIST = $(man_MANS) libtest.c idmapd.conf
-LIBS = -lldap
 
 #	XXX: also exclude debian/files and debian/files.new ? do a clean??
 dist-hook:
--- libnfsidmap-0.17/libnfsidmap.c
+++ libnfsidmap-0.17/libnfsidmap.c
@@ -166,11 +166,13 @@
 extern struct trans_func nss_trans;
 extern struct trans_func umichldap_trans;
 
-#define TR_SIZE 2
-static struct trans_func * t_array[TR_SIZE] = {
-	[0] = &nss_trans,
-	[1] = &umichldap_trans,
+static struct trans_func * t_array[] = {
+	&nss_trans,
+#ifdef ENABLE_LDAP
+	&umichldap_trans,
+#endif
 };
+#define TR_SIZE (sizeof(t_array)/sizeof(*t_array))
 
 int
 set_trans_method(char *method)
--- libnfsidmap-0.17/umich_ldap.c
+++ libnfsidmap-0.17/umich_ldap.c
@@ -32,6 +32,8 @@
  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#ifdef ENABLE_LDAP
+
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <netdb.h>
@@ -1019,3 +1021,5 @@
 	.gid_to_name    = umichldap_gid_to_name,
 	.gss_princ_to_grouplist = umichldap_gss_princ_to_grouplist,
 };
+
+#endif

--Boundary-00=_uym6EALRyN2D8+p
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--Boundary-00=_uym6EALRyN2D8+p
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_uym6EALRyN2D8+p--
