From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind   
 instead of getaddrinfo
Date: Tue, 7 Apr 2009 16:30:19 -0400
Message-ID: <20090407163019.4eae5367@tleilax.poochiereds.net>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
	<20090407131151.69203e5e@tleilax.poochiereds.net>
	<49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com>
	<20090407155305.5790407c@tleilax.poochiereds.net>
	<49dbb129.02045a0a.023b.6bc7@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46761 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760335AbZDGUbN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2009 16:31:13 -0400
In-Reply-To: <49dbb129.02045a0a.023b.6bc7-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 07 Apr 2009 16:01:31 -0400
Tom Talpey <tmtalpey@gmail.com> wrote:
> 
> >
> >I'd rather see these people just update their kernels so that this
> >isn't needed...
> 
> Agreed. Would it make sense to log a message when the default 2049
> is used? At least then, there's a chance an admin will know it's needed.
> 

That's sounds reasonable. I've already asked Steve to commit the latest
set, but we should be able to add something like this untested patch on
top of it.

If it looks ok, I'll test it out and officially resend it...

Thoughts?

----------------[snip]--------------------

>From 7ac66dd50eafec3db3c816203fc24b9b72ff1f36 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 7 Apr 2009 16:27:13 -0400
Subject: [PATCH] nfs-utils: log warning when gssd detects an older kernel that doesn't send port in upcall

Older kernels don't send port information in the upcall. This could
cause mounts to fail for mysterious reasons. Log a warning the first
time that gssd encounters an upcall without any port information in it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 02239d2..90182b0 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -99,6 +99,8 @@
  *      and rescan the whole {pipefs_nfsdir} when this happens.
  */
 
+static int warned_on_port_field;
+
 struct pollfd * pollarray;
 
 int pollsize;  /* the size of pollaray (in pollfd's) */
@@ -228,8 +230,16 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	}
 
 	cb_port[0] = '\0';
-	if ((p = strstr(buf, "port")) != NULL)
+	if ((p = strstr(buf, "port")) != NULL) {
 		sscanf(p, "port: %127s\n", cb_port);
+	} else if (!warned_on_port_field) {
+		warned_on_port_field = 1;
+		printerr(0, "WARNING: This kernel does not send port info "
+			    "in the upcall. That support was added in "
+			    "upstream kernel version 2.6.24. Using "
+			    "non-standard ports may not work with this "
+			    "kernel.\n");
+	}
 
 	/* check service, program, and version */
 	if(memcmp(service, "nfs", 3)) return -1;
-- 
1.6.0.6
