From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] idmapd: remove idmapd.conf.man (moved to libnfsidmap)
Date: Wed, 26 Aug 2009 21:23:44 -0400
Message-ID: <20090827012343.22149.10793.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:47315 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754450AbZH0Bvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2009 21:51:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The man page for idmapd.conf has become stagnant and out of date
here.  Move it to the libnfsidmap package with the code that parses
it so that it can more easily be maintained.

(libnfsidmap-0.23 now has the updated man page)

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/idmapd/Makefile.am     |    6 +--
 utils/idmapd/idmapd.conf.man |   74 ------------------------------------------
 2 files changed, 2 insertions(+), 78 deletions(-)
 delete mode 100644 utils/idmapd/idmapd.conf.man

diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index eb393df..7c3f828 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -1,6 +1,5 @@
 ## Process this file with automake to produce Makefile.in
 
-man5_MANS	= idmapd.conf.man
 man8_MANS	= idmapd.man
 
 RPCPREFIX	= rpc.
@@ -8,7 +7,6 @@ KPREFIX		= @kprefix@
 sbin_PROGRAMS	= idmapd
 
 EXTRA_DIST = \
-	$(man5_MANS) \
 	$(man8_MANS) \
 	idmapd.conf
 
@@ -49,8 +47,8 @@ uninstall-hook:
 
 # XXX This makes some assumptions about what automake does.
 # XXX But there is no install-man-hook or install-man-local.
-install-man: install-man5 install-man8 install-man-links
-uninstall-man: uninstall-man5 uninstall-man8 uninstall-man-links
+install-man: install-man8 install-man-links
+uninstall-man: uninstall-man8 uninstall-man-links
 
 install-man-links:
 	(cd $(DESTDIR)$(man8dir) && \
diff --git a/utils/idmapd/idmapd.conf.man b/utils/idmapd/idmapd.conf.man
deleted file mode 100644
index 02722b1..0000000
--- a/utils/idmapd/idmapd.conf.man
+++ /dev/null
@@ -1,74 +0,0 @@
-.\"	$OpenBSD: mdoc.template,v 1.6 2001/02/03 08:22:44 niklas Exp $
-.\"
-.\" The following requests are required for all man pages.
-.Dd July 16, 2003
-.Dt idmapd.conf 5
-.Os
-.Sh NAME
-.Nm idmapd.conf
-.Nd configuration file for idmapd, the NFSv4 ID <-> Name Mapper
-.Sh SYNOPSIS
-Configuration file for idmapd, the NFSv4 ID <-> Name Mapper
-.Sh DESCRIPTION
-The
-.Nm
-configuration file has two sections, initiated by the strings
-[General] and [Mapping].  Each section may contain lines of the form
-.Dl ""
-.Dl variable = value
-.Dl ""
-The variables allowed in the General section are
-.Va Verbosity,
-.Va Pipefs-Directory,
-and
-.Va Domain,
-whose values have the same effect as the arguments to the
-.Fl v,
-.Fl p,
-and
-.Fl d
-commandline options, respectively.  The variables allowed in the
-Mapping section are
-.Va Nobody-User
-and
-.Va Nobody-Group,
-which have the same effect as the
-.Fl U
-and
-.Fl G
-commandline options.
-'
-.Sh EXAMPLES
-'
-An example
-.Pa /etc/idmapd.conf
-file:
-'
-.Bd -literal
-[General]
-
-Verbosity = 0
-Pipefs-Directory = /var/lib/nfs/rpc_pipefs
-Domain = localdomain
-
-[Mapping]
-
-Nobody-User = nobody
-Nobody-Group = nobody
-.Ed
-'
-.Sh SEE ALSO
-.Xr idmapd 8
-.\".Sh SEE ALSO
-.\".Xr nylon.conf 4
-.\" .Sh COMPATIBILITY
-.\".Sh STANDARDS
-.\".Sh ACKNOWLEDGEMENTS
-.Sh AUTHORS
-The idmapd software has been developed by Marius Aamodt Eriksen
-.Aq marius@citi.umich.edu .
-.\" .Sh HISTORY
-.\".Sh BUGS
-.\"Please report any bugs to Marius Aamodt Eriksen
-.\".Aq marius@monkey.org .
-.\" .Sh CAVEATS

