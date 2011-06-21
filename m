Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:61624 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1FURLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2011 13:11:30 -0400
Received: by qyk9 with SMTP id 9so1820231qyk.19
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2011 10:11:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com, bfields@fieldses.org,
        sweet_f_a@gmx.de
Subject: [PATCH] manpage: add info about IPv6 configuration to exports(5) (try #3)
Date: Tue, 21 Jun 2011 13:11:24 -0400
Message-Id: <1308676284-20731-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The parts of the exports(5) manpage that discuss IP addressing neglect
IPv6 configuration. Update to include info on how to export to IPv6
subnets and addresses, and add a line demonstrating that to the EXAMPLE
section.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/exportfs/exports.man |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 241b3af..8e6f880 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -47,7 +47,7 @@ NFS clients may be specified in a number of ways:
 .IP "single host
 This is the most common format. You may specify a host either by an
 abbreviated name recognized be the resolver, the fully qualified domain
-name, or an IP address.
+name, an IPv4 address, or an IPv6 address.
 .IP "IP networks
 You can also export directories to all hosts on an IP (sub-) network
 simultaneously. This is done by specifying an IP address and netmask pair
@@ -56,8 +56,9 @@ as
 where the netmask can be specified in dotted-decimal format, or as a
 contiguous mask length.
 For example, either `/255.255.252.0' or `/22' appended
-to the network base IPv4 address results in identical subnetworks with 10 bits of
-host. Wildcard characters generally do not work on IP addresses, though they
+to the network base IPv4 address results in identical subnetworks with 10 bits
+of host. IPv6 addresses must use a contiguous mask length. Wildcard characters
+generally do not work on IP addresses, though they
 may work by accident when reverse DNS lookups fail.
 .IP "wildcards
 Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
@@ -486,6 +487,7 @@ The format for extra export tables is the same as
 /home/joe       pc001(rw,all_squash,anonuid=150,anongid=100)
 /pub            *(ro,insecure,all_squash)
 /srv/www        \-sync,rw server @trusted @external(ro)
+/foo            2001:db8:9:e54::/64(rw) 192.0.2.0/24(rw)
 '''/pub/private    (noaccess)
 .fi
 .PP
@@ -501,7 +503,8 @@ option in this entry also allows clients with NFS implementations that
 don't use a reserved port for NFS.
 The sixth line exports a directory read-write to the machine 'server'
 as well as the `@trusted' netgroup, and read-only to netgroup `@external',
-all three mounts with the `sync' option enabled.
+all three mounts with the `sync' option enabled. The seventh line exports
+a directory to both an IPv6 and an IPv4 subnet.
 ''' The last line denies all NFS clients
 '''access to the private directory.
 '''.SH CAVEATS
-- 
1.7.5.4

