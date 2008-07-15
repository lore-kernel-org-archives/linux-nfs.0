From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Tue, 15 Jul 2008 11:31:47 -0400
Message-ID: <76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
References: <18556.16890.235207.711721@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:1345 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762042AbYGOPcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 11:32:06 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2612170ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 08:31:49 -0700 (PDT)
In-Reply-To: <18556.16890.235207.711721-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 2:21 AM, Neil Brown <neilb@suse.de> wrote:
>
>
> Hi Steve,
>  if you agree with the following patch, it can be pulled from
>
>  git://neil.brown.name/nfs-utils for-steved
>
>
> Thanks,
> NeilBrown
>
>
> From: Neil Brown <neilb@suse.de>
> Date: Tue, 15 Jul 2008 06:11:55 +1000
> Subject: [PATCH] sm-notify: perform DNS lookup in the background.
>
> If an NFS server has no network connectivity when it reboots,
> it will block in sm-notify waiting for DNS lookup for a potentially
> large number of hosts.  This is not helpful and just annoys the
> sysadmin.
>
> So do the DNS lookup in the backgrounded phase of sm-notify,
> before sending off the NOTIFY requests.

Good idea.  A couple of minor comments below.

>
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  utils/statd/sm-notify.c |   23 ++++++++++++++---------
>  1 files changed, 14 insertions(+), 9 deletions(-)
>
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index bb67c37..8e00aac 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -286,6 +286,20 @@ notify(void)
>                        hp = hosts;
>                        hosts = hp->next;
>
> +                       if (hp->ai == NULL)
> +                               hp->ai = host_lookup(AF_UNSPEC, hp->name);
> +                       if (hp->ai == NULL) {
> +                               nsm_log(LOG_WARNING,
> +                                       "%s doesn't seem to be a valid address,"
> +                                       " skipped",
> +                                       hp->name);
> +                               unlink(hp->path);
> +                               free(hp->name);
> +                               free(hp->path);
> +                               free(hp);
> +                               continue;
> +                       }
> +

Arguably it would be cleaner architecturally if the DNS lookup were in
notify_host().  Since doing it in notify() means you will be looking
up these addresses on retries, maybe the host_lookup() call should be
integrated into the "If we retransmitted 4 times" logic.  That would
be an opportunity to fix the addrinfo leak in there.

[Note that freeaddrinfo(3) simply walks the list of addrinfo
structures and frees them.  By setting ai_next to NULL in some of the
addrinfo structures, sm-notify is orphaning them -- freeaddrinfo(3)
will never find them].

>                        notify_host(sock, hp);
>
>                        /* Set the timeout for this call, using an
> @@ -532,15 +546,6 @@ get_hosts(const char *dirname)

You should probably fix the documenting comment for get_hosts() --
"convert them to host entries" might be more precise.

>                if (stat(path, &stb) < 0)
>                        continue;
>
> -               host->ai = host_lookup(AF_UNSPEC, de->d_name);
> -               if (! host->ai) {
> -                       nsm_log(LOG_WARNING,
> -                               "%s doesn't seem to be a valid address, skipped",
> -                               de->d_name);
> -                       unlink(path);
> -                       continue;
> -               }
> -
>                host->last_used = stb.st_mtime;
>                host->timeout = NSM_TIMEOUT;
>                host->path = strdup(path);
> --
> 1.5.6.2

-- 
Chuck Lever
