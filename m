Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns201214.ovh.net ([91.121.117.65]:49984 "EHLO ns201214.ovh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757110Ab0EKNhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 09:37:20 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by ns201214.ovh.net (Postfix) with ESMTP id DA9CDA7CA6D
	for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 14:53:40 +0200 (CEST)
Received: from ns201214.ovh.net ([127.0.0.1])
	by localhost (ns201214.ovh.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VCkfFWcGLLOW for <linux-nfs@vger.kernel.org>;
	Tue, 11 May 2010 14:53:33 +0200 (CEST)
Received: from ns201214.ovh.net (localhost.localdomain [127.0.0.1])
	by ns201214.ovh.net (Postfix) with ESMTP id 7E894A7CA6A
	for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 14:53:25 +0200 (CEST)
Received: from [127.0.0.1] (unknown [41.201.232.91])
	(Authenticated sender: ramzi@nomado.eu)
	by ns201214.ovh.net (Postfix) with ESMTP id 72C81A7CA6F
	for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 14:53:24 +0200 (CEST)
Message-ID: <4BE956AC.3070303@nomado.eu>
Date: Tue, 11 May 2010 14:07:56 +0100
From: HABIB Ramzi <ramzi@nomado.eu>
Reply-To: ramzi@nomado.eu
To: linux-nfs@vger.kernel.org
Subject: libnfsidmap: Virtual domains/users handling with at sign in idmap
Content-Type: multipart/mixed;
 boundary="------------050001000601090603040307"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------050001000601090603040307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Subject: libnfsidmap: Virtual domains/users handling with at sign in idmap
Package: libnfsidmap
Version: 0.23
Severity: normal
Tags: patch

*** Please type your report below this line ***

Idmap fails to map uid to localname or vice versa in case an 'at' ( @ ) sign
is included in the localname.
This is particularly the case of virtual domains username where
a user@virtual_domain is in fact the username and its @ sign conflicts with
username@idmap_domain format used by idmap to handle uid/localname 
conversions.
Where username = user@virtual_domain.
Idmap is still able to map uid/localname correctly when the username 
does not
include an @ sign.
Both NFS Server and Client are PAM/NSS clients of an OpenLDAP Server that
handles users & groups. NFSv4 is used and without kerberos and "nsswitch"
Translation method is used rather than umich_ldap.
Idmap looks for the first occurrence of and @ sign in the name string
and assumes that the @ sign is the one of user@virtual_domain rather than
using the one of username@idmap_domain (user@virtual_domain@idmap_domain).
The function "strip_domain" is defined in nss.c file and uses "strchr"
function on line 138 to find the first occurrence of an @ sign from the name
string.
As the name string includes 2 occurrences, the domain resulting from that
(virtual_domain@idmap_domain) fails to match with the configured idmap 
domain
(idmap_domain) and this causes idmap returning a null value.
Switching from "strchr" to "strrchr" simply fix the problem as it would look
for the last occurrence rather than the first one and therefore has a 
resulting
domain that matched the idmap one.
This obviously makes sense as a URI should be read from right to left 
and not
from left to right when handling domains.
The idmap domain is this way the root domain and all virtual domains 
included
in the username it handles will not conflicts with it.

A patch is included here below :

libnfsidmap_0.23_fix_at_sign_user_with_domain.diff

//////////////////////////////////////////////////////////////////

--- libnfsidmap-0.23.orig/nss.c    2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c    2010-05-11 15:02:13.000000000 +0200
@@ -135,7 +135,7 @@
      char *l = NULL;
      int len;

-    c = strchr(name, '@');
+    c = strrchr(name, '@');
      if (c == NULL && domain != NULL)
          goto out;
      if (c == NULL && domain == NULL) {

//////////////////////////////////////////////////////////////////

The patch applies to all archs.
Versions checked :
Debian :
libnfsidmap2 0.18-0 (oldstable)
libnfsidmap2 0.20-1 (stable)
libnfsidmap2 0.23-2 (testing,unstable)

-- System Information:
Debian Release: 5.0.4
   APT prefers stable
   APT policy: (500, 'stable')
Architecture: amd64 (x86_64)

Kernel: Linux 2.6.26-2-amd64 (SMP w/1 CPU core)
Locale: LANG=fr_FR.UTF-8, LC_CTYPE=fr_FR.UTF-8 (charmap=UTF-8)
Shell: /bin/sh linked to /bin/bash

Versions of packages libnfsidmap2 depends on:
ii  libc6                       2.7-18lenny2 GNU C Library: Shared libraries
ii  libldap-2.4-2               2.4.11-1+lenny1   OpenLDAP libraries

Ramzi HABIB
ramzi <at> nomado.eu

--------------050001000601090603040307
Content-Type: text/plain;
 name="libnfsidmap_0.23_fix_at_sign_user_with_domain.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="libnfsidmap_0.23_fix_at_sign_user_with_domain.diff"

--- libnfsidmap-0.23.orig/nss.c	2009-07-29 22:19:06.000000000 +0200
+++ libnfsidmap-0.23/nss.c	2010-05-11 15:02:13.000000000 +0200
@@ -135,7 +135,7 @@
 	char *l = NULL;
 	int len;
 
-	c = strchr(name, '@');
+	c = strrchr(name, '@');
 	if (c == NULL && domain != NULL)
 		goto out;
 	if (c == NULL && domain == NULL) {

--------------050001000601090603040307--
