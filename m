Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35127 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbeF0Kdd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 06:33:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id z137-v6so4925928wmc.0
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 03:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180519203436.9560.83609.stgit@klimt.1015granger.net>
References: <20180519203436.9560.83609.stgit@klimt.1015granger.net>
From: Naruto Nguyen <narutonguyen2018@gmail.com>
Date: Wed, 27 Jun 2018 17:33:31 +0700
Message-ID: <CANpxKHGTMfhy1HKWVxqV9XyyWW5ieL-NR7VjTZs26B5Rc6nayw@mail.gmail.com>
Subject: Re: [PATCH RFC] Make bindresvport(3) avoid IANA-assigned ports
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Thanks a lot for your patch. Looks like it works as expected. But I
have read about this patch at another thread
https://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/thread/20180601155057.GA23836%40suse.de/#msg36332436.

In this thread, as I understand this patch still does not resolve a
problem regarding to deadlock when getservbyport can use NIS as you
and Thorsten discussed, right? I am not quite clear about the use case
of this deadlock so please correct me if I am wrong.

Could you please let me know which is the final solution for this
issue, your patch or Thorsten's blacklist hack solution (SUSE 15 years
solution), or you are investigating another solution?

Thanks,
Brs,
Bao


On 20 May 2018 at 03:39, Chuck Lever <chuck.lever@oracle.com> wrote:
> There have been complaints over many years that bindresvport(3) can
> bind to a reserved port that is also assigned to a well-known
> service, preventing that service from starting as long as bindresv-
> port's caller is still squatting on that port.  For instance:
>
> https://sourceware.org/bugzilla/show_bug.cgi?id=1014
> https://bugzilla.redhat.com/show_bug.cgi?id=103401
> https://bugzilla.novell.com/show_bug.cgi?id=262341
> https://bugs.debian.org/638322
> http://cyberelk.net/tim/software/portreserve/
> https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bindresvport_blacklist.diff/
>
> statd, for example, has a long-running downcall client that can
> squat on a reserved port for as long as the system is up. statd is
> courteous enough to try hard to avoid choosing a well-known port
> for its downcall client.
>
> bindresvport(3) is a generic API, and therefore can't simply skip
> all ports assigned in /etc/services, as that leaves a pretty skimpy
> set of remaining ports that can be used.
>
> An explicit blacklist might be used to prevent the use of just a
> few common services. Although /etc/bindresvport.blacklist is
> historically supported on several distributions, there have been
> some objections to that approach in the long term:
>
> - It should be improved by making the blacklist a directory (say,
>   /etc/bindresvport.blacklist.d/) so that other packages can
>   easily insert new blacklisted ports when they are installed.
>
> - But it would be even nicer if there wasn't an additional adminis-
>   trative interface, particularly one that largely duplicates what
>   is already in /etc/services .
>
> Thus I'm proposing a slightly different approach: Change bindresv-
> port(3) so it tries to skip IANA-assigned ports; if no unused port
> is found, search again, but allow the use of IANA-assigned ports
> this time.
>
> This gives reasonable avoidance behavior but still allows operation
> when the set of unassigned ports runs out, and does not introduce
> another administrative interface.
>
> See also commit c254b435007e.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  src/bindresvport.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> Hi Naruto-
>
> Please apply this patch to the latest libtirpc source tree. Rebuild
> it, then "sudo make install". Then rebuild rpcinfo to pull in the
> rebuilt version of libtirpc.
>
> diff --git a/src/bindresvport.c b/src/bindresvport.c
> index 2d8f2bc..6423afb 100644
> --- a/src/bindresvport.c
> +++ b/src/bindresvport.c
> @@ -85,6 +85,7 @@ bindresvport_sa(sd, sa)
>         socklen_t salen;
>         int nports;
>         int endport = ENDPORT;
> +       int pass;
>         int i;
>
>         mutex_lock(&port_lock);
> @@ -130,11 +131,15 @@ bindresvport_sa(sd, sa)
>          }
>          res = -1;
>          errno = EADDRINUSE;
> -               again:
> +        pass = 1;
> +       setservent(1);
> +again:
>          for (i = 0; i < nports; ++i) {
>                  *portp = htons(port++);
>                   if (port > endport)
>                          port = startport;
> +               if (pass == 1 && getservbyport(*portp, NULL))
> +                       continue;
>                  res = bind(sd, sa, salen);
>                 if (res >= 0 || errno != EADDRINUSE)
>                         break;
> @@ -144,8 +149,10 @@ bindresvport_sa(sd, sa)
>             endport = STARTPORT - 1;
>             nports = STARTPORT - LOWPORT;
>             port = LOWPORT + port % (STARTPORT - LOWPORT);
> +           pass++;
>             goto again;
>         }
> +       endservent();
>         mutex_unlock(&port_lock);
>
>          return (res);
>
