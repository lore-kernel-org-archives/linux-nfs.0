From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: Patch to prevent rpc.gssd spamming logs when Kerberos credentials are expired
Date: Tue, 25 Nov 2008 17:49:55 -0500
Message-ID: <4d569c330811251449u3ca7701eu41a633b4a95f3bb4@mail.gmail.com>
References: <39d46ab50811251322j73574e1cg19a1650c8f567463@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Andrew Pollock" <apollock@google.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:55572 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbYKYWt4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2008 17:49:56 -0500
Received: by yx-out-2324.google.com with SMTP id 8so118843yxm.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2008 14:49:55 -0800 (PST)
In-Reply-To: <39d46ab50811251322j73574e1cg19a1650c8f567463-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2008 at 4:22 PM, Andrew Pollock <apollock@google.com> wrote:
> Hi,
>
> We've seen excessive (disk filling) log spam from rpc.gssd where users
> mount their home directory via Kerberised NFS, and their Kerberos TGT
> expires. You get lots of noise like described at
> https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/293705
>
> Attached is the patch that we've been using to address this.
>
> regards
>
> Andrew

Hi Andrew,

I looked at the referenced bug discussion.  Looking at the supplied
patch, I suspect you either (1) normally run rpc.gssd with "-v", or
(2) you are depending on the other part of the original patch that
decreases verbosity (copied below).  If the latter is true, then
shouldn't it be sufficient to only change the error messages from
level 0 to level 1 as I've shown below?

--- nfs-utils-1.1.2.orig/utils/gssd/err_util.c
+++ nfs-utils-1.1.2/utils/gssd/err_util.c
@@ -49,6 +49,10 @@
 {
 	va_list args;

+	/* Decrease verbosity so we don't log so much */
+	if ((priority - verbosity) > 1)
+		return;
+
 	/* Don't bother formatting a message we're never going to print! */
 	if (priority > verbosity)
 		return;.



--- nfs-utils-1.1.2.orig/utils/gssd/gssd_proc.c
+++ nfs-utils-1.1.2/utils/gssd/gssd_proc.c
@@ -743,7 +743,7 @@
 	}

 	if (!authgss_get_private_data(auth, &pd)) {
-		printerr(0, "WARNING: Failed to obtain authentication "
+		printerr(1, "WARNING: Failed to obtain authentication "
 			    "data for user with uid %d for server %s\n",
 			 uid, clp->servername);
 		goto out_return_error;
only in patch2:
unchanged:
--- nfs-utils-1.1.2.orig/utils/gssd/gss_util.c
+++ nfs-utils-1.1.2/utils/gssd/gss_util.c
@@ -122,7 +122,7 @@
 				"gss_display_status called from %s\n", m);
 			break;
 		} else {
-			printerr(0, "ERROR: GSS-API: (%s) error in %s(): %s\n",
+			printerr(1, "ERROR: GSS-API: (%s) error in %s(): %s\n",
 			    typestr, m, (char *)msg.value);
 		}
