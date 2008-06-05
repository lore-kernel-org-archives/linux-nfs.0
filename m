From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: [PATCH] nfs-utils:  "nfsstat -m" should report nfsv4 mounts too.
Date: Thu, 5 Jun 2008 07:40:14 -0400
Message-ID: <4CC1DC65-88C3-4F26-8FF2-016F6C1173CE@myri.com>
References: <18503.29174.373900.73302@notabene.brown> <18503.29397.511629.809568@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1967 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755478AbYFELkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 07:40:43 -0400
In-Reply-To: <18503.29397.511629.809568-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 5, 2008, at 1:00 AM, Neil Brown wrote:

> That will, of course, report the "nfsd" mount as well, which we don't
> want.  So let's try again.
>
> NeilBrown
>
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index aa6c961..d2cca8d 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -716,7 +716,7 @@ mounts(const char *name)
> 		if (!(type = strtok(NULL, " \t")))
> 			continue;
>
> -		if (strcmp(type, "nfs")) {
> +		if (strcmp(type, "nfs") && strcmp(type,"nfs4")) {
> 		    continue;
> 		}

Don't you want an OR?

+		if (strcmp(type, "nfs") || strcmp(type,"nfs4")) {

Scott
