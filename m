From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: Get rid of empty AUTHORS file (patch)
Date: Mon, 20 Oct 2008 15:41:43 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0810201541090.27240@fbirervta.pbzchgretzou.qr>
References: <alpine.LNX.1.10.0810182047070.17929@fbirervta.pbzchgretzou.qr> <20081020185346.GC25796@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:48228 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbYJTTlp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2008 15:41:45 -0400
In-Reply-To: <20081020185346.GC25796@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Monday 2008-10-20 14:53, J. Bruce Fields wrote:
>On Sat, Oct 18, 2008 at 08:48:11PM -0400, Jan Engelhardt wrote:
>> the AUTHORS file reads:
>> 
>> 	This is a dummy AUTHORS file to make automake happy.
>> 
>> You can make automake happy in an IMO better way:
>> 
>> 	AUTOMAKE_OPTIONS = foreign
>> 
>> at the top of the toplevel Makefile.am.
>> (I usually also prefer "AUTOMAKE_OPTIONS = subdir-objs" next to 
>> foreign.)
>
>The quickest way to get changes into nfs-utils these days is a patch
>sent to steved@redhat.com against git://linux-nfs.org/nfs-utils.

commit 81d1d9fbab29e45fbdb27a2e0df011f6cd00714a
Author: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Date:   Mon Oct 20 15:40:27 2008 -0400

build: remove redundant AUTHORS file

One can use the --foreign automake option to make it not enforce
presence of an AUTHORS file.

Signed-off-by: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
---
 AUTHORS     |    1 -
 Makefile.am |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)
 delete mode 100644 AUTHORS
 mode change 100644 => 100755 autogen.sh

diff --git a/AUTHORS b/AUTHORS
deleted file mode 100644
index 9205d1e..0000000
--- a/AUTHORS
+++ /dev/null
@@ -1 +0,0 @@
-This is a dummy AUTHORS file to make automake happy.
diff --git a/Makefile.am b/Makefile.am
index ec8e832..88ae210 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -1,5 +1,7 @@
 ## Process this file with automake to produce Makefile.in
 
+AUTOMAKE_OPTIONS = foreign
+
 SUBDIRS = tools support utils linux-nfs
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/autogen.sh b/autogen.sh
old mode 100644
new mode 100755
