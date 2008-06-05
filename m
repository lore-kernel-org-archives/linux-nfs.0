From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils:  "nfsstat -m" should report nfsv4 mounts too.
Date: Thu, 5 Jun 2008 15:00:05 +1000
Message-ID: <18503.29397.511629.809568@notabene.brown>
References: <18503.29174.373900.73302@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35264 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402AbYFEFAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 01:00:12 -0400
In-Reply-To: message from Neil Brown on Thursday June 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday June 5, neilb@suse.de wrote:
> 
> nfsstat -m lists all current nfs mounts, with the mount options.
> It does this by reading /proc/mounts and looking for mounts of type
> "nfs".
> It really should check for "nfs4" as well.  For simplicity, just check
> the first 3 characters of the type.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index aa6c961..488c845 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -716,7 +716,7 @@ mounts(const char *name)
>  		if (!(type = strtok(NULL, " \t")))
>  			continue;
>  
> -		if (strcmp(type, "nfs")) {
> +		if (strncmp(type, "nfs", 3)) {
>  		    continue;
>  		}
>  

(stupid. stupid. stupid).

That will, of course, report the "nfsd" mount as well, which we don't
want.  So let's try again.

NeilBrown


diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index aa6c961..d2cca8d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -716,7 +716,7 @@ mounts(const char *name)
 		if (!(type = strtok(NULL, " \t")))
 			continue;
 
-		if (strcmp(type, "nfs")) {
+		if (strcmp(type, "nfs") && strcmp(type,"nfs4")) {
 		    continue;
 		}
 
