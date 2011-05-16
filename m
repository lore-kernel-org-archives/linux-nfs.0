Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101Ab1EPNzX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2011 09:55:23 -0400
Date: Mon, 16 May 2011 09:56:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Luca Giuzzi <luca.giuzzi@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.idmapd dies with 'I/O possible'
Message-ID: <20110516095615.5d788c1a@corrin.poochiereds.net>
In-Reply-To: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
References: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 16 May 2011 15:38:27 +0200
Luca Giuzzi <luca.giuzzi@gmail.com> wrote:

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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks correct to me:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
