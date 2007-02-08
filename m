From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 02/12] Add AM_MAINTAINER_MODE to configure.in
Date: Thu, 08 Feb 2007 17:26:59 -0500
Message-ID: <20070208222658.23464.10122.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk3-0006sC-2x
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:47 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk4-0006mL-PL
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:49 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

As requested by "Steinar H. Gunderson" <sgunderson@bigfoot.com>, add
AM_MAINTAINER_MODE to configure.in.  See the description of this
macro below:

  `AM_MAINTAINER_MODE' disables the so called "rebuild rules" bys
  default. If you have `AM_MAINTAINER_MODE' in `configure.ac', and
  run `./configure && make', then `make' will *never* attempt to
  rebuild `configure', `Makefile.in's, Lex or Yacc outputs, etc.
  I.e., this disables build rules for files which are usually
  distributed and that users should normally not have to update.

     If you run `./configure --enable-maintainer-mode', then these
     rebuild rules will be active.
---

 configure.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index 757ebb8..99adee8 100644
--- a/configure.in
+++ b/configure.in
@@ -8,6 +8,7 @@ AC_CONFIG_MACRO_DIR(aclocal)
 AM_INIT_AUTOMAKE
 AC_PREREQ(2.59)
 AC_PREFIX_DEFAULT(/usr)
+AM_MAINTAINER_MODE
 
 dnl *************************************************************
 dnl * Define the set of applicable options

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
