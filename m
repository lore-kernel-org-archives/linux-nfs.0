Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37735 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbeBHSgW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Feb 2018 13:36:22 -0500
Received: by mail-it0-f41.google.com with SMTP id h129so7557477ita.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Feb 2018 10:36:22 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
Date: Thu, 8 Feb 2018 13:36:19 -0500
Cc: Tom Talpey <tom@talpey.com>, Guillem Jover <gjover@sipwise.com>,
        Steve Dickson <SteveD@redhat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
 <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
 <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
To: Chuck Lever <chucklever@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 8, 2018, at 1:07 PM, Chuck Lever <chucklever@gmail.com> wrote:
>=20
> On Fri, Jan 12, 2018 at 2:19 PM, Tom Talpey <tom@talpey.com> wrote:
>> On 1/12/2018 1:41 PM, Guillem Jover wrote:
>>>=20
>>> On Thu, 2018-01-11 at 10:18:46 -0500, Steve Dickson wrote:
>>>>=20
>>>> Overall I think this makes sense, but this eliminates 240 privilege
>>>> ports and worried we would run out of port (due to them in =
TIME_WAIT)
>>>> during a v3 mount storms. A port goes into TIME_WAIT after a v3 =
mount
>>>> is done... But on the other hand v3 is no longer the default and
>>>> there are 784 available ports.... Hopefully that is enough.
>>>=20
>>>=20
>>> Hmm, those numbers do not match my own. bindresvport() uses the port
>>> range between 512 and 1023 inclusive. On my Debian stable (stretch)
>>=20
>>=20
>> Properly speaking, no service should be binding to any port but the
>> one it is assigned to. This includes 0-1023 as well as 1024-49151.
>>=20
>> https://tools.ietf.org/html/rfc6335
>>=20
>> See last quoted sentence from:
>>=20
>> =
https://www.iana.org/assignments/service-names-port-numbers/service-names-=
port-numbers.xhtml
>>=20
>>>> Service names are assigned on a first-come, first-served process, =
as
>>>> documented in [RFC6335].
>>>>=20
>>>> Port numbers are assigned in various ways, based on three ranges: =
System
>>>> Ports (0-1023), User Ports (1024-49151), and the Dynamic and/or =
Private
>>>> Ports (49152-65535); the difference uses of these ranges is =
described in
>>>> [RFC6335]. According to Section 8.1.2 of [RFC6335], System Ports =
are
>>>> assigned by the "IETF Review" or "IESG Approval" procedures =
described in
>>>> [RFC8126]. User Ports are assigned by IANA using the "IETF Review" =
process,
>>>> the "IESG Approval" process, or the "Expert Review" process, as per
>>>> [RFC6335]. Dynamic Ports are not assigned.
>>>>=20
>>>> The registration procedures for service names and port numbers are
>>>> described in [RFC6335].
>>>>=20
>>>> Assigned ports both System and User ports SHOULD NOT be used =
without
>>>> or prior to IANA registration.
>>=20
>>=20
>> Tom.
>=20
> At Steve's request, I've filed a bug against libtirpc:
>=20
> https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D320
>=20
> to document the issue and the rationales for alternate solutions.
>=20
> I'm fairly confident that bindresvport(3) is never necessary for
> svc_tli_create(3). It is arguably also not appropriate for
> clnt_tli_create(3). Therefore IMO it should be removed from those code
> paths. That by itself would provide some relief and would eliminate
> the need to alter the current bindresvport(3) implementation (say, by
> introducing a blacklisting mechanism).
>=20
> As Tom mentioned above, RFC 6335 describes a port range that will
> never interfere with service ports allocated by IANA. This range is
> known as the Dynamic or Private port range (49152 - 65535). On my
> systems, bind(3) already frequently allocates from the Dynamic port
> range purely by chance.
>=20
> To completely prevent the accidental allocation of a well-known
> service port, a special internal wrapper for the bind(3) system call
> (similar to bindresvport(3)) can be constructed for libtirpc that
> allocates only from the Dynamic port range whenever a caller does not
> specify a port, making libtirpc adhere to the Best Common Practices
> outlined in RFC 6335, and thereby closing this window for user space
> RPC services completely.
>=20
> A more thorough solution IMO would be to fix up the bind(3) system
> call to allocate only from the Dynamic port range whenever a caller
> does not specify a port. This would take care of not only user space
> RPC services but of all dynamically allocated ports on the system,
> including ports dynamically allocated in the kernel.

Replace "bind(3)" with "bind(2)" throughout. Oops.

--
Chuck Lever
chucklever@gmail.com



