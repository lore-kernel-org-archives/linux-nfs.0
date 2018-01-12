Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-05.prod.phx3.secureserver.net ([68.178.252.234]:33444
        "EHLO p3plsmtpa12-05.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965044AbeALT0x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 14:26:53 -0500
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
To: Guillem Jover <gjover@sipwise.com>,
        Steve Dickson <SteveD@RedHat.com>,
        libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
Date: Fri, 12 Jan 2018 14:19:33 -0500
MIME-Version: 1.0
In-Reply-To: <20180112184151.GA10261@thunder.hadrons.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/12/2018 1:41 PM, Guillem Jover wrote:
> On Thu, 2018-01-11 at 10:18:46 -0500, Steve Dickson wrote:
>> Overall I think this makes sense, but this eliminates 240 privilege
>> ports and worried we would run out of port (due to them in TIME_WAIT)
>> during a v3 mount storms. A port goes into TIME_WAIT after a v3 mount
>> is done... But on the other hand v3 is no longer the default and
>> there are 784 available ports.... Hopefully that is enough.
> 
> Hmm, those numbers do not match my own. bindresvport() uses the port
> range between 512 and 1023 inclusive. On my Debian stable (stretch)

Properly speaking, no service should be binding to any port but the
one it is assigned to. This includes 0-1023 as well as 1024-49151.

https://tools.ietf.org/html/rfc6335

See last quoted sentence from:

https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml

>> Service names are assigned on a first-come, first-served process, as
>> documented in [RFC6335].
>> 
>> Port numbers are assigned in various ways, based on three ranges: System
>> Ports (0-1023), User Ports (1024-49151), and the Dynamic and/or Private
>> Ports (49152-65535); the difference uses of these ranges is described in
>> [RFC6335]. According to Section 8.1.2 of [RFC6335], System Ports are 
>> assigned by the "IETF Review" or "IESG Approval" procedures described in 
>> [RFC8126]. User Ports are assigned by IANA using the "IETF Review" process, 
>> the "IESG Approval" process, or the "Expert Review" process, as per 
>> [RFC6335]. Dynamic Ports are not assigned.
>> 
>> The registration procedures for service names and port numbers are
>> described in [RFC6335].
>> 
>> Assigned ports both System and User ports SHOULD NOT be used without
>> or prior to IANA registration.

Tom.




> and unstable systems these are the number of registered ports in
> /etc/services:
> 
>    ,---
>    # UDP
>    $ awk '/^[^#]/ { print $2 }' /etc/services | \
>      sed -n -e 's,/udp,,p' | \
>      while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
>      then echo $port; fi; done | sort -u | wc -l
>    31
>    # TCP
>    $ awk '/^[^#]/ { print $2 }' /etc/services | \
>      sed -n -e 's,/tcp,,p' | \
>      while read port; do if [ $port -ge 512 -a $port -lt 1024 ]; \
>      then echo $port; fi; done | sort -u | wc -l
>    48
>    `---
> 
> So that's pretty low. Not as low as the 9 listed in
> /etc/bindresvport.blacklist, but as I've mentioned on the other reply,
> given that the list is incomplete and that does not support dynamically
> registering the ports being actively used on the current system with a
> ".d/" style fragments directory, it would eventually require to ship
> all the ports already listed in /etc/services anyway, which gains us
> nothing.
> 
> In addition I notice now that even the comment in that file (at least on
> Debian) is bogus, as it does not account for ports between 512 and 599:
> 
>    ,--- /etc/bindresvport.blacklist
>    #
>    # This file contains a list of port numbers between 600 and 1024,
>    # which should not be used by bindresvport. bindresvport is mostly
>    # called by RPC services. This mostly solves the problem, that a
>    # RPC service uses a well known port of another service.
>    #
>    `---
> 
> :)
> 
> Thanks,
> Guillem
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
