From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] libexport.a: export_find() should handle address parsing
	errors
Date: Thu, 15 Apr 2010 11:25:25 -0400
Message-ID: <20100415152524.4716.57643.stgit@localhost.localdomain>
References: <20100415152401.4716.83632.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:56373 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0DOPZ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 11:25:28 -0400
Received: by qw-out-2122.google.com with SMTP id 8so478820qwh.37
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:25:27 -0700 (PDT)
In-Reply-To: <20100415152401.4716.83632.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An address mask parsing error can cause client_init(), and therefore
client_dup(), to make our process exit suddenly.  Soon we want to add
more complex address parsing in client_init(), so we need this
interface to be a little more robust.

Since export_find() can return NULL in some cases, it can handle NULL
returns from its subroutines if an address parsing error occurs, or if
memory is exhausted.  Allow for client_dup() to return NULL instead of
exiting sideways.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index ddc8a84..3e4da69 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -129,6 +129,10 @@ export_dup(nfs_export *exp, struct hostent *hp)
 	if (exp->m_export.e_hostname)
 		new->m_export.e_hostname = xstrdup(exp->m_export.e_hostname);
 	clp = client_dup(exp->m_client, hp);
+	if (clp == NULL) {
+		export_free(new);
+		return NULL;
+	}
 	clp->m_count++;
 	new->m_client = clp;
 	new->m_mayexport = exp->m_mayexport;

