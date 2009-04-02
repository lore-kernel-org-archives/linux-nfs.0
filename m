From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/2] svcgssd: check the return code from qword_eol() and log
	failures
Date: Wed, 01 Apr 2009 20:05:57 -0400
Message-ID: <20090402000557.3234.97118.stgit@rock.citi.umich.edu>
References: <20090402000430.3234.81110.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41257 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231AbZDBAgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 20:36:00 -0400
In-Reply-To: <20090402000430.3234.81110.stgit-Cm81N35Y91hZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

If qword_eol() fails while writing the context information, log
an indication of the failure.

This addresses at least one cause of the intermittent, and
previously undiagnosed, problem of the server returning
GSS_S_NO_CONTEXT when a context was seemingly successfully
created and sent down to the kernel.  In my case there was a
mis-match between kernel and user-land configuration resulting in
the proper kernel module not being loaded. Therefore the write
of the context failed, but was not logged by svcgssd.  When the
kernel goes to find the resulting context, it was really not
there and correctly returned GSS_S_NO_CONTEXT to the client.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd_proc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index b390bea..6f2ba61 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -109,6 +109,10 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	qword_print(f, fname);
 	qword_printhex(f, context_token->value, context_token->length);
 	err = qword_eol(f);
+	if (err) {
+		printerr(1, "WARNING: error writing to downcall channel "
+			 "%s: %s\n", SVCGSSD_CONTEXT_CHANNEL, strerror(errno));
+	}
 	fclose(f);
 	return err;
 out_err:

