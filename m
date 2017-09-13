Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56716 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:36 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 12/14] exportfs: add support for "vsock:" exports(5) syntax
Date: Wed, 13 Sep 2017 11:26:48 +0100
Message-Id: <20170913102650.10377-13-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow exports to be restricted to AF_VSOCK clients:

  # exportfs vsock:3:/export

and:

  # cat /etc/exports
  /export       vsock:*(rw,no_root_squash,insecure,subtree_check)

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 utils/exportfs/exportfs.c  | 32 ++++++++++++++++++++++++++++++++
 utils/exportfs/exports.man | 12 ++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 3ded733..6bf67f1 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -299,6 +299,20 @@ static int exportfs_generic(char *arg, char *options, int verbose)
 	return 0;
 }
 
+static int exportfs_vsock(char *arg, char *options, int verbose)
+{
+	char *path;
+
+	if ((path = strchr(arg + strlen("vsock:"), ':')) != NULL)
+		*path++ = '\0';
+
+	if (!path || *path != '/')
+		return 1;
+
+	exportfs_parsed(arg, path, options, verbose);
+	return 0;
+}
+
 static int exportfs_ipv6(char *arg, char *options, int verbose)
 {
 	char *path, *c;
@@ -332,6 +346,8 @@ exportfs(char *arg, char *options, int verbose)
 
 	if (*arg == '[')
 		failed = exportfs_ipv6(arg, options, verbose);
+	else if (strncmp(arg, "vsock:", strlen("vsock:")) == 0)
+		failed = exportfs_vsock(arg, options, verbose);
 	else
 		failed = exportfs_generic(arg, options, verbose);
 	if (failed)
@@ -412,6 +428,20 @@ static int unexportfs_generic(char *arg, int verbose)
 	return 0;
 }
 
+static int unexportfs_vsock(char *arg, int verbose)
+{
+	char *path;
+
+	if ((path = strchr(arg + strlen("vsock:"), ':')) != NULL)
+		*path++ = '\0';
+
+	if (!path || *path != '/')
+		return 1;
+
+	unexportfs_parsed(arg, path, verbose);
+	return 0;
+}
+
 static int unexportfs_ipv6(char *arg, int verbose)
 {
 	char *path, *c;
@@ -445,6 +475,8 @@ unexportfs(char *arg, int verbose)
 
 	if (*arg == '[')
 		failed = unexportfs_ipv6(arg, verbose);
+	else if (strncmp(arg, "vsock:", strlen("vsock:")) == 0)
+		failed = unexportfs_vsock(arg, verbose);
 	else
 		failed = unexportfs_generic(arg, verbose);
 	if (failed)
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index d8de6be..35b5612 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -47,7 +47,9 @@ NFS clients may be specified in a number of ways:
 .IP "single host
 You may specify a host either by an
 abbreviated name recognized be the resolver, the fully qualified domain
-name, an IPv4 address, or an IPv6 address. IPv6 addresses must not be
+name, an IPv4 address, an IPv6 address, or a vsock address prefixed with
+.BR vsock: .
+IPv6 addresses must not be
 inside square brackets in /etc/exports lest they be confused with
 character-class wildcard matches.
 .IP "IP networks
@@ -492,6 +494,12 @@ export entry for
 .B /home/joe
 in the example section below, which maps all requests to uid 150 (which
 is supposedly that of user joe).
+.SS Multiple Address Families
+When machines are specified using IPv4, IPv6, or vsock addresses they have
+access from the given network addresses.  The wildcard \fI*\fR by itself
+matches machines of all address families.
+.BR vsock:*
+can be used to match only vsock machines.
 .SS Extra Export Tables
 After reading 
 .I /etc/exports 
@@ -510,7 +518,7 @@ The format for extra export tables is the same as
 .nf
 .ta +3i
 # sample /etc/exports file
-/               master(rw) trusty(rw,no_root_squash)
+/               master(rw) trusty(rw,no_root_squash) vsock:3(rw)
 /projects       proj*.local.domain(rw)
 /usr            *.local.domain(ro) @trusted(rw)
 /home/joe       pc001(rw,all_squash,anonuid=150,anongid=100)
-- 
2.13.5

