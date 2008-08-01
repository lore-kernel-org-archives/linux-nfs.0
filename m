From: Neil Brown <neilb@suse.de>
Subject: Re: mount issue with Mac OSX and --manage-gids, client hangs
Date: Fri, 1 Aug 2008 15:44:08 +1000
Message-ID: <18578.41640.740866.153235@notabene.brown>
References: <20080731204701.GE26609@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:60482 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbYHAFoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2008 01:44:15 -0400
In-Reply-To: message from Alex Samad on Friday August 1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday August 1, alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org wrote:
> 
> I tracked it down to --manage-gids - when I remove this from
> /etc/defaults/nfs-kernel-server everything works fine.
> 
> Note though, the UID's, GIDs are not synced between the linux box and
> the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
> exist on the nas box

Yes... I never tested that case, did I :-(

This patch should fix it.  Are you able to compile a new nfs-utils
with this patch applied and test the mountd from there?

Thanks,
NeilBrown


diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f555dcc..48d737b 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -158,7 +158,8 @@ void auth_unix_gid(FILE *f)
 		qword_printint(f, ngroups);
 		for (i=0; i<ngroups; i++)
 			qword_printint(f, groups[i]);
-	}
+	} else
+		qword_printint(f, 0);
 	qword_eol(f);
 	if (groups != glist)
 		free(groups);
