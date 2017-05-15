Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:35310 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdEOB6W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 14 May 2017 21:58:22 -0400
Received: by mail-ua0-f193.google.com with SMTP id e28so9078928uah.2
        for <linux-nfs@vger.kernel.org>; Sun, 14 May 2017 18:58:21 -0700 (PDT)
MIME-Version: 1.0
From: Guido Vranken <guidovranken@gmail.com>
Date: Mon, 15 May 2017 03:58:20 +0200
Message-ID: <CAO5O-ELFAoyHZWnvyh_vtdB0vJiEf-wsBgKF8SG+Y_Bj4fK1kw@mail.gmail.com>
Subject: [PATCH] rpcbind: libtirpc fixes for CVE-2017-8779
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix for CVE-2017-8779
Signed-off-by: Guido Vranken <guidovranken@gmail.com>
---
 src/rpc_generic.c |  8 ++++++++
 src/rpcb_prot.c   | 22 ++++++++++++++--------
 src/rpcb_st_xdr.c |  9 +++++----
 src/xdr.c         | 30 +++++++++++++++++++++++++-----
 4 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/src/rpc_generic.c b/src/rpc_generic.c
index 2f09a8f..589cbd5 100644
--- a/src/rpc_generic.c
+++ b/src/rpc_generic.c
@@ -615,6 +615,9 @@ __rpc_taddr2uaddr_af(int af, const struct netbuf *nbuf)

     switch (af) {
     case AF_INET:
+        if (nbuf->len < sizeof(*sin)) {
+            return NULL;
+        }
         sin = nbuf->buf;
         if (inet_ntop(af, &sin->sin_addr, namebuf, sizeof namebuf)
             == NULL)
@@ -626,6 +629,9 @@ __rpc_taddr2uaddr_af(int af, const struct netbuf *nbuf)
         break;
 #ifdef INET6
     case AF_INET6:
+        if (nbuf->len < sizeof(*sin6)) {
+            return NULL;
+        }
         sin6 = nbuf->buf;
         if (inet_ntop(af, &sin6->sin6_addr, namebuf6, sizeof namebuf6)
             == NULL)
@@ -667,6 +673,8 @@ __rpc_uaddr2taddr_af(int af, const char *uaddr)

     port = 0;
     sin = NULL;
+    if (uaddr == NULL)
+        return NULL;
     addrstr = strdup(uaddr);
     if (addrstr == NULL)
         return NULL;
diff --git a/src/rpcb_prot.c b/src/rpcb_prot.c
index 43fd385..a923c8e 100644
--- a/src/rpcb_prot.c
+++ b/src/rpcb_prot.c
@@ -41,6 +41,7 @@
 #include <rpc/types.h>
 #include <rpc/xdr.h>
 #include <rpc/rpcb_prot.h>
+#include "rpc_com.h"

 bool_t
 xdr_rpcb(xdrs, objp)
@@ -53,13 +54,13 @@ xdr_rpcb(xdrs, objp)
     if (!xdr_u_int32_t(xdrs, &objp->r_vers)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_netid, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_netid, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_addr, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_addr, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_owner, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_owner, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     return (TRUE);
@@ -159,19 +160,19 @@ xdr_rpcb_entry(xdrs, objp)
     XDR *xdrs;
     rpcb_entry *objp;
 {
-    if (!xdr_string(xdrs, &objp->r_maddr, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_maddr, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_nc_netid, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_nc_netid, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     if (!xdr_u_int32_t(xdrs, &objp->r_nc_semantics)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_nc_protofmly, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_nc_protofmly, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->r_nc_proto, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->r_nc_proto, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     return (TRUE);
@@ -292,7 +293,7 @@ xdr_rpcb_rmtcallres(xdrs, p)
     bool_t dummy;
     struct r_rpcb_rmtcallres *objp = (struct r_rpcb_rmtcallres *)(void *)p;

-    if (!xdr_string(xdrs, &objp->addr, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->addr, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     if (!xdr_u_int(xdrs, &objp->results.results_len)) {
@@ -312,6 +313,11 @@ xdr_netbuf(xdrs, objp)
     if (!xdr_u_int32_t(xdrs, (u_int32_t *) &objp->maxlen)) {
         return (FALSE);
     }
+
+    if (objp->maxlen > RPC_MAXDATASIZE) {
+        return (FALSE);
+    }
+
     dummy = xdr_bytes(xdrs, (char **)&(objp->buf),
             (u_int *)&(objp->len), objp->maxlen);
     return (dummy);
diff --git a/src/rpcb_st_xdr.c b/src/rpcb_st_xdr.c
index 08db745..28e6a48 100644
--- a/src/rpcb_st_xdr.c
+++ b/src/rpcb_st_xdr.c
@@ -37,6 +37,7 @@


 #include <rpc/rpc.h>
+#include "rpc_com.h"

 /* Link list of all the stats about getport and getaddr */

@@ -58,7 +59,7 @@ xdr_rpcbs_addrlist(xdrs, objp)
         if (!xdr_int(xdrs, &objp->failure)) {
         return (FALSE);
         }
-        if (!xdr_string(xdrs, &objp->netid, (u_int)~0)) {
+        if (!xdr_string(xdrs, &objp->netid, RPC_MAXDATASIZE)) {
         return (FALSE);
         }

@@ -109,7 +110,7 @@ xdr_rpcbs_rmtcalllist(xdrs, objp)
         IXDR_PUT_INT32(buf, objp->failure);
         IXDR_PUT_INT32(buf, objp->indirect);
     }
-    if (!xdr_string(xdrs, &objp->netid, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->netid, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     if (!xdr_pointer(xdrs, (char **)&objp->next,
@@ -147,7 +148,7 @@ xdr_rpcbs_rmtcalllist(xdrs, objp)
         objp->failure = (int)IXDR_GET_INT32(buf);
         objp->indirect = (int)IXDR_GET_INT32(buf);
     }
-    if (!xdr_string(xdrs, &objp->netid, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->netid, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     if (!xdr_pointer(xdrs, (char **)&objp->next,
@@ -175,7 +176,7 @@ xdr_rpcbs_rmtcalllist(xdrs, objp)
     if (!xdr_int(xdrs, &objp->indirect)) {
         return (FALSE);
     }
-    if (!xdr_string(xdrs, &objp->netid, (u_int)~0)) {
+    if (!xdr_string(xdrs, &objp->netid, RPC_MAXDATASIZE)) {
         return (FALSE);
     }
     if (!xdr_pointer(xdrs, (char **)&objp->next,
diff --git a/src/xdr.c b/src/xdr.c
index f3fb9ad..b9a1558 100644
--- a/src/xdr.c
+++ b/src/xdr.c
@@ -42,8 +42,10 @@
 #include <stdlib.h>
 #include <string.h>

+#include <rpc/rpc.h>
 #include <rpc/types.h>
 #include <rpc/xdr.h>
+#include <rpc/rpc_com.h>

 typedef quad_t          longlong_t;     /* ANSI long long type */
 typedef u_quad_t        u_longlong_t;   /* ANSI unsigned long long type */
@@ -53,7 +55,6 @@ typedef u_quad_t        u_longlong_t;   /* ANSI
unsigned long long type */
  */
 #define XDR_FALSE    ((long) 0)
 #define XDR_TRUE    ((long) 1)
-#define LASTUNSIGNED    ((u_int) 0-1)

 /*
  * for unit alignment
@@ -629,6 +630,7 @@ xdr_bytes(xdrs, cpp, sizep, maxsize)
 {
     char *sp = *cpp;  /* sp is the actual string pointer */
     u_int nodesize;
+    bool_t ret, allocated = FALSE;

     /*
      * first deal with the length since xdr bytes are counted
@@ -652,6 +654,7 @@ xdr_bytes(xdrs, cpp, sizep, maxsize)
         }
         if (sp == NULL) {
             *cpp = sp = mem_alloc(nodesize);
+            allocated = TRUE;
         }
         if (sp == NULL) {
             warnx("xdr_bytes: out of memory");
@@ -660,7 +663,14 @@ xdr_bytes(xdrs, cpp, sizep, maxsize)
         /* FALLTHROUGH */

     case XDR_ENCODE:
-        return (xdr_opaque(xdrs, sp, nodesize));
+        ret = xdr_opaque(xdrs, sp, nodesize);
+        if ((xdrs->x_op == XDR_DECODE) && (ret == FALSE)) {
+            if (allocated == TRUE) {
+                free(sp);
+                *cpp = NULL;
+            }
+        }
+        return (ret);

     case XDR_FREE:
         if (sp != NULL) {
@@ -754,6 +764,7 @@ xdr_string(xdrs, cpp, maxsize)
     char *sp = *cpp;  /* sp is the actual string pointer */
     u_int size;
     u_int nodesize;
+    bool_t ret, allocated = FALSE;

     /*
      * first deal with the length since xdr strings are counted-strings
@@ -793,8 +804,10 @@ xdr_string(xdrs, cpp, maxsize)
     switch (xdrs->x_op) {

     case XDR_DECODE:
-        if (sp == NULL)
+        if (sp == NULL) {
             *cpp = sp = mem_alloc(nodesize);
+            allocated = TRUE;
+        }
         if (sp == NULL) {
             warnx("xdr_string: out of memory");
             return (FALSE);
@@ -803,7 +816,14 @@ xdr_string(xdrs, cpp, maxsize)
         /* FALLTHROUGH */

     case XDR_ENCODE:
-        return (xdr_opaque(xdrs, sp, size));
+        ret = xdr_opaque(xdrs, sp, size);
+        if ((xdrs->x_op == XDR_DECODE) && (ret == FALSE)) {
+            if (allocated == TRUE) {
+                free(sp);
+                *cpp = NULL;
+            }
+        }
+        return (ret);

     case XDR_FREE:
         mem_free(sp, nodesize);
@@ -823,7 +843,7 @@ xdr_wrapstring(xdrs, cpp)
     XDR *xdrs;
     char **cpp;
 {
-    return xdr_string(xdrs, cpp, LASTUNSIGNED);
+    return xdr_string(xdrs, cpp, RPC_MAXDATASIZE);
 }

 /*
-- 
2.1.4
