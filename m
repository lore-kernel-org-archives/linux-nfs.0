Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta-out1.inet.fi ([62.71.2.233]:42843 "EHLO johanna1.inet.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753537AbdLNRzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 12:55:02 -0500
Message-ID: <1513273692.24220.47.camel@pp1.inet.fi>
Subject: Re: [systemd-devel] [PATCH] rpcbind.service: Not pulling the
 rpcbind.target
From: Uoti Urpala <uoti.urpala@pp1.inet.fi>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Date: Thu, 14 Dec 2017 19:48:12 +0200
In-Reply-To: <20171214170544.11793-1-steved@redhat.com>
References: <20171214170544.11793-1-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-12-14 at 12:05 -0500, Steve Dickson wrote:
> According to systemd.special(7) manpage:
> 
> rpcbind.target
>     The portmapper/rpcbind pulls in this target and orders itself
> before it, to indicate its availability. systemd automatically adds
> dependencies of type After= for this target unit to all SysV init
> script service units with an LSB header referring to the "$portmap"
> facility.


> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index f8cfa9f..2b49c24 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
>  
>  # Make sure we use the IP addresses listed for
>  # rpcbind.socket, no matter how this unit is started.
> -Wants=rpcbind.socket
> -After=rpcbind.socket
> +Wants=rpcbind.socket rpcbind.target
> +After=rpcbind.socket rpcbind.target

Is this needed when the service has socket activation support? If the
only interaction with it is through the socket, it shouldn't matter
even if the service is not actually up yet - clients can already open
connections to the socket regardless.

And regardless, that "After" for rpcbind.target seems backwards.
Shouldn't it be "Before", so that the target being up signals that the
service has already been started?

Not directly related, but if that comment is accurate and the socket
should be used "no matter what", perhaps that should be "Requires"
instead of "Wants" so that if the socket could not be opened for some
reason, the service fails instead of starting without socket
activation?

