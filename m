Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56111 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964998AbeALTMW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 14:12:22 -0500
Date: Fri, 12 Jan 2018 20:12:47 +0100
From: Thorsten Kukuk <kukuk@suse.de>
To: Guillem Jover <gjover@sipwise.com>,
        Steve Dickson <SteveD@RedHat.com>,
        libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports
 registered in /etc/services
Message-ID: <20180112191247.GA9828@suse.de>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180112184151.GA10261@thunder.hadrons.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 12, Guillem Jover wrote:

> On Thu, 2018-01-11 at 10:18:46 -0500, Steve Dickson wrote:
> > Overall I think this makes sense, but this eliminates 240 privilege
> > ports and worried we would run out of port (due to them in TIME_WAIT)
> > during a v3 mount storms. A port goes into TIME_WAIT after a v3 mount
> > is done... But on the other hand v3 is no longer the default and
> > there are 784 available ports.... Hopefully that is enough.
> 
> Hmm, those numbers do not match my own. bindresvport() uses the port
> range between 512 and 1023 inclusive. On my Debian stable (stretch)
> and unstable systems these are the number of registered ports in
> /etc/services:
> 
>   ,---
>   # UDP
>   $ awk '/^[^#]/ { print $2 }' /etc/services | \
>     sed -n -e 's,/udp,,p' | \
>     while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
>     then echo $port; fi; done | sort -u | wc -l
>   31
>   # TCP
>   $ awk '/^[^#]/ { print $2 }' /etc/services | \
>     sed -n -e 's,/tcp,,p' | \
>     while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
>     then echo $port; fi; done | sort -u | wc -l
>   48
>   `---

This numbers are only low, since Debian is using a hand selected
/etc/services file with most entries missing. But your change 
would not be limited to libtirpc on Debian.
I have 276 for TCP and 276 for UDP, that's much, much more. So
already about 50% of the available range.

  Thorsten

-- 
Thorsten Kukuk, Distinguished Engineer, Senior Architect SLES & CaaSP
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)
