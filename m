From: Chuck Lever <chuck.lever@oracle.com>
Subject: build problems with latest nfs-utils
Date: Sun, 15 Jul 2007 19:59:18 -0400
Message-ID: <469AB4D6.20902@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030507000500010806090906"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAE0t-0000Ph-EU
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 17:00:31 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAE0v-00088y-RR
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 17:00:35 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------030507000500010806090906
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

I updated my git repo to the latest version of nfs-utils, and now I can=20
no longer build nfs-utils.  I use

./configure --disable-gss --disable-nfsv4

and get these compilation errors:

Making all in nfs
make[2]: Entering directory `/u/cel/nfs-utils/support/nfs'
gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I../../support/include=20
-D_GNU_SOURCE -Wall  -pipe -g -O2 -MT exports.o -MD -MP -MF=20
.deps/exports.Tpo -c -o exports.o exports.c
exports.c:33:27: error: pseudoflavors.h: No such file or directory
exports.c:38: error: array type has incomplete element type
exports.c:39: error: =91RPC_AUTH_GSS_KRB5=92 undeclared here (not in a fu=
nction)
exports.c:40: error: =91RPC_AUTH_GSS_KRB5I=92 undeclared here (not in a=20
function)
exports.c:41: error: =91RPC_AUTH_GSS_KRB5P=92 undeclared here (not in a=20
function)
exports.c:42: error: =91RPC_AUTH_GSS_LKEY=92 undeclared here (not in a fu=
nction)
exports.c:43: error: =91RPC_AUTH_GSS_LKEYI=92 undeclared here (not in a=20
function)
exports.c:44: error: =91RPC_AUTH_GSS_LKEYP=92 undeclared here (not in a=20
function)
exports.c:45: error: =91RPC_AUTH_GSS_SPKM=92 undeclared here (not in a fu=
nction)
exports.c:46: error: =91RPC_AUTH_GSS_SPKMI=92 undeclared here (not in a=20
function)
exports.c:47: error: =91RPC_AUTH_GSS_SPKMP=92 undeclared here (not in a=20
function)
exports.c: In function =91secinfo_show=92:
exports.c:209: error: dereferencing pointer to incomplete type
exports.c:212: error: dereferencing pointer to incomplete type
exports.c: In function =91find_flavor=92:
exports.c:423: error: increment of pointer to unknown structure
exports.c:423: error: arithmetic on pointer to an incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
exports.c:424: error: dereferencing pointer to incomplete type
make[2]: *** [exports.o] Error 1
make[2]: Leaving directory `/u/cel/nfs-utils/support/nfs'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/u/cel/nfs-utils/support'
make: *** [all-recursive] Error 1
[cel@monet nfs-utils]$

--------------030507000500010806090906
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle USA;Corporate Architecture
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------030507000500010806090906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------030507000500010806090906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030507000500010806090906--
