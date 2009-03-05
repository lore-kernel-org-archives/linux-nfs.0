From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] gssd: include gssapi/gssapi.h before write_bytes.h
Date: Wed, 04 Mar 2009 19:03:06 -0500
Message-ID: <20090305000305.28749.67361.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:26813 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbZCEAFX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:05:23 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In gssd/context_lucid.c, ensure that gss_buffer_desc and gss_OID_desc
are defined before write_bytes.h, which uses these definitions, is
included.  With TI-RPC, these definitions are not provided by
rpc/rpc.h.

It appears that <gssapi/gssapi_krb5.h> already includes krb5.h and
gssapi.h (on my system, anyway) so let's drop those includes.

Ideally write_bytes.h itself should include the needed headers, but
some source files that use Heimdal include a different, Heimdal-
compatible, header to get these definitions.

Pointed-out-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/context_lucid.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 3243d53..af7de58 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -42,17 +42,17 @@
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
+
+#include <gssapi/gssapi_krb5.h>
+
 #include "gss_util.h"
 #include "gss_oids.h"
 #include "err_util.h"
 #include "context.h"
 
-#include <krb5.h>
-#include <gssapi/gssapi.h>
 #ifndef OM_uint64
 typedef uint64_t OM_uint64;
 #endif
-#include <gssapi/gssapi_krb5.h>
 
 static int
 write_lucid_keyblock(char **p, char *end, gss_krb5_lucid_key_t *key)

