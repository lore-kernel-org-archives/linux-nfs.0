Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.sipwise.com ([92.42.136.241]:42640 "EHLO mx1.sipwise.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964967AbeALSl4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 13:41:56 -0500
Date: Fri, 12 Jan 2018 19:41:51 +0100
From: Guillem Jover <gjover@sipwise.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
Message-ID: <20180112184151.GA10261@thunder.hadrons.org>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-01-11 at 10:18:46 -0500, Steve Dickson wrote:
> Overall I think this makes sense, but this eliminates 240 privilege
> ports and worried we would run out of port (due to them in TIME_WAIT)
> during a v3 mount storms. A port goes into TIME_WAIT after a v3 mount
> is done... But on the other hand v3 is no longer the default and
> there are 784 available ports.... Hopefully that is enough.

Hmm, those numbers do not match my own. bindresvport() uses the port
range between 512 and 1023 inclusive. On my Debian stable (stretch)
and unstable systems these are the number of registered ports in
/etc/services:

  ,---
  # UDP
  $ awk '/^[^#]/ { print $2 }' /etc/services | \
    sed -n -e 's,/udp,,p' | \
    while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
    then echo $port; fi; done | sort -u | wc -l
  31
  # TCP
  $ awk '/^[^#]/ { print $2 }' /etc/services | \
    sed -n -e 's,/tcp,,p' | \
    while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
    then echo $port; fi; done | sort -u | wc -l
  48
  `---

So that's pretty low. Not as low as the 9 listed in
/etc/bindresvport.blacklist, but as I've mentioned on the other reply,
given that the list is incomplete and that does not support dynamically
registering the ports being actively used on the current system with a
".d/" style fragments directory, it would eventually require to ship
all the ports already listed in /etc/services anyway, which gains us
nothing.

In addition I notice now that even the comment in that file (at least on
Debian) is bogus, as it does not account for ports between 512 and 599:

  ,--- /etc/bindresvport.blacklist
  #
  # This file contains a list of port numbers between 600 and 1024,
  # which should not be used by bindresvport. bindresvport is mostly
  # called by RPC services. This mostly solves the problem, that a
  # RPC service uses a well known port of another service.
  #
  `---

:)

Thanks,
Guillem
