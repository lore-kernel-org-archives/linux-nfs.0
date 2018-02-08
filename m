Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:34350 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbeBHSHu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Feb 2018 13:07:50 -0500
Received: by mail-vk0-f46.google.com with SMTP id f186so3302993vkc.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Feb 2018 10:07:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
References: <20180110004920.11100-1-gjover@sipwise.com> <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org> <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
From: Chuck Lever <chucklever@gmail.com>
Date: Thu, 8 Feb 2018 13:07:49 -0500
Message-ID: <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
To: Tom Talpey <tom@talpey.com>
Cc: Guillem Jover <gjover@sipwise.com>,
        Steve Dickson <SteveD@redhat.com>,
        libtirpc <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 12, 2018 at 2:19 PM, Tom Talpey <tom@talpey.com> wrote:
> On 1/12/2018 1:41 PM, Guillem Jover wrote:
>>
>> On Thu, 2018-01-11 at 10:18:46 -0500, Steve Dickson wrote:
>>>
>>> Overall I think this makes sense, but this eliminates 240 privilege
>>> ports and worried we would run out of port (due to them in TIME_WAIT)
>>> during a v3 mount storms. A port goes into TIME_WAIT after a v3 mount
>>> is done... But on the other hand v3 is no longer the default and
>>> there are 784 available ports.... Hopefully that is enough.
>>
>>
>> Hmm, those numbers do not match my own. bindresvport() uses the port
>> range between 512 and 1023 inclusive. On my Debian stable (stretch)
>
>
> Properly speaking, no service should be binding to any port but the
> one it is assigned to. This includes 0-1023 as well as 1024-49151.
>
> https://tools.ietf.org/html/rfc6335
>
> See last quoted sentence from:
>
> https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
>
>>> Service names are assigned on a first-come, first-served process, as
>>> documented in [RFC6335].
>>>
>>> Port numbers are assigned in various ways, based on three ranges: System
>>> Ports (0-1023), User Ports (1024-49151), and the Dynamic and/or Private
>>> Ports (49152-65535); the difference uses of these ranges is described in
>>> [RFC6335]. According to Section 8.1.2 of [RFC6335], System Ports are
>>> assigned by the "IETF Review" or "IESG Approval" procedures described in
>>> [RFC8126]. User Ports are assigned by IANA using the "IETF Review" process,
>>> the "IESG Approval" process, or the "Expert Review" process, as per
>>> [RFC6335]. Dynamic Ports are not assigned.
>>>
>>> The registration procedures for service names and port numbers are
>>> described in [RFC6335].
>>>
>>> Assigned ports both System and User ports SHOULD NOT be used without
>>> or prior to IANA registration.
>
>
> Tom.

At Steve's request, I've filed a bug against libtirpc:

https://bugzilla.linux-nfs.org/show_bug.cgi?id=320

to document the issue and the rationales for alternate solutions.

I'm fairly confident that bindresvport(3) is never necessary for
svc_tli_create(3). It is arguably also not appropriate for
clnt_tli_create(3). Therefore IMO it should be removed from those code
paths. That by itself would provide some relief and would eliminate
the need to alter the current bindresvport(3) implementation (say, by
introducing a blacklisting mechanism).

As Tom mentioned above, RFC 6335 describes a port range that will
never interfere with service ports allocated by IANA. This range is
known as the Dynamic or Private port range (49152 - 65535). On my
systems, bind(3) already frequently allocates from the Dynamic port
range purely by chance.

To completely prevent the accidental allocation of a well-known
service port, a special internal wrapper for the bind(3) system call
(similar to bindresvport(3)) can be constructed for libtirpc that
allocates only from the Dynamic port range whenever a caller does not
specify a port, making libtirpc adhere to the Best Common Practices
outlined in RFC 6335, and thereby closing this window for user space
RPC services completely.

A more thorough solution IMO would be to fix up the bind(3) system
call to allocate only from the Dynamic port range whenever a caller
does not specify a port. This would take care of not only user space
RPC services but of all dynamically allocated ports on the system,
including ports dynamically allocated in the kernel.

-- 
"We cannot take our next breath without the exhale."
 -- Ellen Scott Grable
