Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759752Ab3DBRtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 13:49:13 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnCE8014533
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:12 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnB4G006259
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:12 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] Fix segfault when using -R option
Date: Tue,  2 Apr 2013 13:49:05 -0400
Message-Id: <1364924947-16985-2-git-send-email-simo@redhat.com>
In-Reply-To: <1364924947-16985-1-git-send-email-simo@redhat.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The getopt string did not add : after the R option resulting in a sefgault
whenever -R was used as optarg is NULL and it is dereferenced.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gssd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 0be251781bacaa562270f773341126bc95ca6b45..07b1e52e6b84e9bcba96e7a63b0505ca7823482a 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -102,7 +102,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
-- 
1.7.1

