Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525Ab1EPOXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2011 10:23:21 -0400
Message-ID: <4DD13350.1000207@RedHat.com>
Date: Mon, 16 May 2011 10:23:12 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Luca Giuzzi <luca.giuzzi@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.idmapd dies with 'I/O possible'
References: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
In-Reply-To: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 05/16/2011 09:38 AM, Luca Giuzzi wrote:
> Dear All,
>  we have had problems on some of our machines (all Fedora 14), where
> rpc.idmapd used to die with an `I/O possible' message at (basically)
> random times. A strace suggested the issue being in nfsopen() where a
> signal type is reset before notification is disabled; a signal at just
> the right time might be the cause of the problem; see
> https://bugzilla.redhat.com/show_bug.cgi?id=684308
> I am now proposing the (trivial) patch to the list as well.
> 
> Best Regards,
>   luca giuzzi
> 
> --- nfs-utils-1.2.3/utils/idmapd/idmapd.c.orig	2011-05-13
> 16:27:08.000000000 +0200
> +++ nfs-utils-1.2.3/utils/idmapd/idmapd.c	2011-05-13 16:27:16.000000000 +0200
> @@ -778,8 +778,8 @@ nfsopen(struct idmap_client *ic)
>  	} else {
>  		event_set(&ic->ic_event, ic->ic_fd, EV_READ, nfscb, ic);
>  		event_add(&ic->ic_event, NULL);
> -		fcntl(ic->ic_dirfd, F_SETSIG, 0);
>  		fcntl(ic->ic_dirfd, F_NOTIFY, 0);
> +		fcntl(ic->ic_dirfd, F_SETSIG, 0);
>  		if (verbose > 0)
>  			xlog_warn("Opened %s", ic->ic_path);
>  	}
I just updated the bz with these questions, but we can have the 
conversation here...

I'm just a bit concerned by the fact that there are
a couple of places that sets F_SETSIG and then sets F_NOTIFY, 
so does that mean those places are potential race cases as 
well?

Also, after you applied this patch, did the problem go away?
Finally, how often did this problem occur?

tia,

steved.

