Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161028Ab2JXSLd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:33 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBXiZ005435
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:33 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSE020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:33 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5] Fixed warnings in src/g_initialize.c
Date: Wed, 24 Oct 2012 14:08:41 -0400
Message-Id: <1351102124-24036-3-git-send-email-steved@redhat.com>
In-Reply-To: <1351102124-24036-1-git-send-email-steved@redhat.com>
References: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yao Zhao <yao.zhao@windriver.com>

g_initialize.c: In function 'linux_initialize':
g_initialize.c:275:5: warning: implicit declaration of function 'getuid'
[-Wimplicit-function-declaration]
g_initialize.c:275:5: warning: implicit declaration of function
'geteuid' [-Wimplicit-function-declaration]

Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/g_initialize.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/src/g_initialize.c b/src/g_initialize.c
index 908398e..d1cb172 100644
--- a/src/g_initialize.c
+++ b/src/g_initialize.c
@@ -29,6 +29,8 @@
 #include "mglueP.h"
 #include <stdlib.h>
 
+#include <unistd.h>   /*getuid, geteuid */
+#include <sys/types.h>
 #include <stdio.h>
 #include <string.h>
 #include <ctype.h>
-- 
1.7.11.7

