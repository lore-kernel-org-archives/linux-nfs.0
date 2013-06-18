Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:52355
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab3FRFVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 01:21:24 -0400
Received: from [127.0.1.1] (localhost [127.0.0.1])
	by snark.thyrsus.com (Postfix) with ESMTP id 9610441791
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 01:13:56 -0400 (EDT)
Content-Type: multipart/mixed; boundary="===============7478725473209331778=="
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Problems in idmapd.conf.5
Message-Id: <20130618051356.9610441791@snark.thyrsus.com>
Date: Tue, 18 Jun 2013 01:13:56 -0400 (EDT)
From: esr@thyrsus.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============7478725473209331778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

This is automatically generated email about markup problems in a man
page for which you appear to be responsible.  If you are not the right
person or list, please tell me so I can correct my database.

See http://catb.org/~esr/doclifter/bugs.html for details on how and
why these patches were generated.  Feel free to email me with any
questions.  Note: These patches do not change the modification date of
any manual page.  You may wish to do that by hand.

I apologize if this message seems spammy or impersonal. The volume of
markup bugs I am tracking is over five hundred - there is no real
alternative to generating bugmail from a database and template.

--
                             Eric S. Raymond

--===============7478725473209331778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Problems with idmapd.conf.5:

Unknown or invalid macro.  That is, one that does not fit in the
macro set that the man page seems to be using.  This is a serious
error; it often means part of your text is being lost or rendered
incorrectly.

Missing or garbled name section.  The most common form of garbling
is a missing - or extra -. Or your manual page may have been generated
by a tool that doesn't emit a NAME section as it should.  Or your page
may add running text such as a version or authorship banner.  These
problems make it impossible to lift the page to DocBook.  They
can also confuse third-party manpage browsers and some implementations
of man -k.

--- idmapd.conf.5-unpatched	2012-07-04 16:51:32.093541654 -0400
+++ idmapd.conf.5	2012-07-04 16:52:14.865540854 -0400
@@ -31,7 +31,7 @@
 .\"
 .TH idmapd.conf 5 "19 Nov 2008"
 .SH NAME
-idmapd.conf
+idmapd.conf \- configuration file for libnfsidmap
 .SH SYNOPSIS
 Configuration file for libnfsidmap.  Used by idmapd and svcgssd to map NFSv4 name to and from ids.
 .SH DESCRIPTION
@@ -266,7 +266,7 @@
 LDAP_server = ldap.domain.org
 LDAP_base = dc=org,dc=domain
 
-.fo
+.fi
 .\"
 .\" -------------------------------------------------------------------
 .\" Additional sections

--===============7478725473209331778==--
