Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:48342 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab1FVNei (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 09:34:38 -0400
Received: by qyk9 with SMTP id 9so451164qyk.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 06:34:38 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.de
Subject: [PATCH] manpage: add section on character class matches to exports(5)
Date: Wed, 22 Jun 2011 09:34:33 -0400
Message-Id: <1308749673-8183-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/exportfs/exports.man |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index d9486e8..b202583 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -47,7 +47,9 @@ NFS clients may be specified in a number of ways:
 .IP "single host
 You may specify a host either by an
 abbreviated name recognized be the resolver, the fully qualified domain
-name, an IPv4 address, or an IPv6 address.
+name, an IPv4 address, or an IPv6 address. IPv6 addresses must not be
+inside square brackets in /etc/exports lest they be confused with
+character-class wildcard matches.
 .IP "IP networks
 You can also export directories to all hosts on an IP (sub-) network
 simultaneously. This is done by specifying an IP address and netmask pair
@@ -57,11 +59,10 @@ where the netmask can be specified in dotted-decimal format, or as a
 contiguous mask length.
 For example, either `/255.255.252.0' or `/22' appended
 to the network base IPv4 address results in identical subnetworks with 10 bits
-of host. IPv6 addresses must use a contiguous mask length. Wildcard characters
-generally do not work on IP addresses, though they
+of host. IPv6 addresses must use a contiguous mask length and must not be inside square brackets to avoid confusion with character-class wildcards. Wildcard characters generally do not work on IP addresses, though they
 may work by accident when reverse DNS lookups fail.
 .IP "wildcards
-Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
+Machine names may contain the wildcard characters \fI*\fR and \fI?\fR, or may contain character class lists within [square brackets].
 This can be used to make the \fIexports\fR file more compact; for instance,
 \fI*.cs.foo.edu\fR matches all hosts in the domain
 \fIcs.foo.edu\fR.  As these characters also match the dots in a domain
@@ -488,6 +489,7 @@ The format for extra export tables is the same as
 /pub            *(ro,insecure,all_squash)
 /srv/www        \-sync,rw server @trusted @external(ro)
 /foo            2001:db8:9:e54::/64(rw) 192.0.2.0/24(rw)
+/build          buildhost[0-9].local.domain(rw)
 '''/pub/private    (noaccess)
 .fi
 .PP
@@ -504,7 +506,8 @@ don't use a reserved port for NFS.
 The sixth line exports a directory read-write to the machine 'server'
 as well as the `@trusted' netgroup, and read-only to netgroup `@external',
 all three mounts with the `sync' option enabled. The seventh line exports
-a directory to both an IPv6 and an IPv4 subnet.
+a directory to both an IPv6 and an IPv4 subnet. The eighth line demonstrates
+a character class wildcard match.
 ''' The last line denies all NFS clients
 '''access to the private directory.
 '''.SH CAVEATS
-- 
1.7.5.4

