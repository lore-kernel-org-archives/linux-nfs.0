Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:44209 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755584Ab3EYCd1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 May 2013 22:33:27 -0400
Date: Sat, 25 May 2013 12:12:48 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsidmap: idmapd.conf.5 man warnings
Message-ID: <20130525021248.GA10636@master.debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm using the patch in this message to build libnfsidmap in Debian.

The following command:

 MANROFFSEQ='' MANWIDTH=80 man --warnings -l -Z ./idmapd.conf.5 >/dev/null 

shows the following warnings:

 <standard input>:237: warning: macro `"' not defined
 <standard input>:269: warning: macro `fo' not defined
 <standard input>:278: warning: macro `".SH' not defined

and the patch below fixes them.

--- a/idmapd.conf.5	2011-12-06 07:28:10.000000000 +1100
+++ b/idmapd.conf.5	2013-05-25 11:07:37.000000000 +1000
@@ -31,7 +31,7 @@
 .\"
 .TH idmapd.conf 5 "19 Nov 2008"
 .SH NAME
-idmapd.conf
+idmapd.conf \- configuration file for libnfsidmap
 .SH SYNOPSIS
 Configuration file for libnfsidmap.  Used by idmapd and svcgssd to map NFSv4 name to and from ids.
 .SH DESCRIPTION
@@ -234,7 +234,6 @@ Number of seconds before timing out an L
 .\" -------------------------------------------------------------------
 .\"
 .SH EXAMPLES
-."
 An example
 .I /etc/idmapd.conf
 file:
@@ -266,7 +265,6 @@ johndoe@OTHER.DOMAIN.ORG = johnny
 LDAP_server = ldap.domain.org
 LDAP_base = dc=org,dc=domain
 
-.fo
 .\"
 .\" -------------------------------------------------------------------
 .\" Additional sections
@@ -275,11 +273,11 @@ LDAP_base = dc=org,dc=domain
 .SH SEE ALSO
 .BR idmapd (8)
 .BR svcgssd (8)
-.".SH COMPATIBILITY
-.".SH STANDARDS
-.".SH ACKNOWLEDGEMENTS
-.".SH AUTHORS
-.".SH HISTORY
+.\".SH COMPATIBILITY
+.\".SH STANDARDS
+.\".SH ACKNOWLEDGEMENTS
+.\".SH AUTHORS
+.\".SH HISTORY
 .SH BUGS
 Report bugs to <nfsv4@linux-nfs.org>
-.".SH CAVEATS
+.\".SH CAVEATS
