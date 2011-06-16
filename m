Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:55863 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650Ab1FPQX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 12:23:29 -0400
Message-Id: <ed7917ba1bcc8fd4537255c00e00b22eee4e7c88.1308241259.git.rees@umich.edu>
In-Reply-To: <cover.1308241259.git.rees@umich.edu>
References: <cover.1308241259.git.rees@umich.edu>
Subject: [PATCH 1/2] add generated .c files to .gitignore
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu, 16 Jun 2011 12:23:25 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 .gitignore |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index f96c819..b8792d0 100644
--- a/.gitignore
+++ b/.gitignore
@@ -15,6 +15,9 @@ basic/test8
 basic/test9
 domount
 getopt
+general/large1.c
+general/large2.c
+general/large3.c
 lock/tlock64
 lock/tlocklfs
 special/bigfile
-- 
1.7.4.1

