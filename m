Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:34800 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934282AbbDXA1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:50 -0400
Received: by wgso17 with SMTP id o17so34830184wgs.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:48 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/7] getrpcent: Fix compilation on glibc
Date: Fri, 24 Apr 2015 02:27:37 +0200
Message-Id: <1429835262-16861-3-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 implicit declaration of function '_yp_check' [-Wimplicit-function-declaration]

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 src/getrpcent.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/src/getrpcent.c b/src/getrpcent.c
index 6da006a..fbb2da4 100644
--- a/src/getrpcent.c
+++ b/src/getrpcent.c
@@ -108,7 +108,7 @@ getrpcbynumber(number)
 	if (d == 0)
 		return (0);
 #ifdef	YP
-        if (!__yp_nomap && _yp_check(&d->domain)) {
+        if (!__yp_nomap && __yp_check(&d->domain)) {
                 sprintf(adrstr, "%d", number);
                 reason = yp_match(d->domain, "rpc.bynumber", adrstr, strlen(adrstr),
                                   &d->current, &d->currentlen);
@@ -175,7 +175,7 @@ setrpcent(f)
 	if (d == 0)
 		return;
 #ifdef	YP
-        if (!__yp_nomap && _yp_check(NULL)) {
+        if (!__yp_nomap && __yp_check(NULL)) {
                 if (d->current)
                         free(d->current);
                 d->current = NULL;
@@ -199,7 +199,7 @@ endrpcent()
 	if (d == 0)
 		return;
 #ifdef	YP
-        if (!__yp_nomap && _yp_check(NULL)) {
+        if (!__yp_nomap && __yp_check(NULL)) {
         	if (d->current && !d->stayopen)
                         free(d->current);
                 d->current = NULL;
@@ -228,7 +228,7 @@ getrpcent()
 	if (d == 0)
 		return(NULL);
 #ifdef	YP
-        if (!__yp_nomap && _yp_check(&d->domain)) {
+        if (!__yp_nomap && __yp_check(&d->domain)) {
                 if (d->current == NULL && d->currentlen == 0) {
                         reason = yp_first(d->domain, "rpc.bynumber",
                                           &d->current, &d->currentlen,
-- 
2.1.4

