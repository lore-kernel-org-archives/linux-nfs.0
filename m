Return-Path: linux-nfs-owner@vger.kernel.org
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:10764 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaAXGdT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 01:33:19 -0500
Received: from demuprx017.emea.nsn-intra.net ([10.150.129.56])
	by demumfd002.nsn-inter.net (8.12.11.20060308/8.12.11) with ESMTP id s0O6XG66019063
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 07:33:16 +0100
Received: from ulegcprs1.emea.nsn-net.net ([10.151.15.253])
	by demuprx017.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id s0O6XF8W008588
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 07:33:15 +0100
Date: Fri, 24 Jan 2014 07:32:02 +0100
From: Robert Schiele <rschiele@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] use NFS4_MAXMINOR instead of hard coded number
Message-ID: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In utils/nfsd/nfsd.c we used hard coded number 2 in option parsing
when referring to NFS4_MAXMINOR.  We should use the defined constant
instead to honor changes to that constant.

Signed-off-by: Robert Schiele <rschiele@gmail.com>
---

This is obviously a rather trivial patch but the hard coded number
hit me when trying to support various kernels with different support
levels.

 utils/nfsd/nfsd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index a9d77ab..c129ee5 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -160,7 +160,7 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > 2) {
+					if (i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
@@ -181,7 +181,7 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > 2) {
+					if (i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-- 
1.8.4
