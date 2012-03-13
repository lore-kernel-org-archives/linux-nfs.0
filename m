Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56932 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab2CMNvr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 09:51:47 -0400
Received: by ghrr11 with SMTP id r11so556636ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2012 06:51:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
	<CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
	<5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
Date: Tue, 13 Mar 2012 09:51:46 -0400
Message-ID: <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com>
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
From: Kevin Coffman <kwc@umich.edu>
To: Michael Weiser <M.Weiser@science-computing.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 5:57 PM, Michael Weiser
<M.Weiser@science-computing.de> wrote:
> Hello Kevin,
>
> On Mon, March 12, 2012 22:10, Kevin Coffman wrote:
>
>> To summarize, the base issue was not with gssd/svcgssd.  It was a
>> change in the Kerberos library code (if I recall correctly, in 1.7 or
>> 1.8??) which ignores the limited enctypes in the server's keytab, and
>> instead uses the Kerberos library's capabilities to assert a subkey.
>
> Are you asking or telling?

I'm telling about what happened.  I don't recall what version the
change was introduced.

> From my understanding up until RFC 4537 (Kerberos Cryptosystem Negotiation
> Extension - which I hadn't heard of up until the day before yesterday), a
> kerberised service had no mechanism to negotiate a ticket or session key
> enctype with the client. This limitation is inherent to the Kerberos
> protocol since the KDC at the time of creating both has no way of asking
> the service which encryption types it currently supports. Instead, when
> adding the service to the realm, a set of keys is put on the KDC and into
> the service's keytab, thus only indirectly telling both, what enctypes the
> service supports.

Prior to the change, the KDC knew what enctypes were in the service's
keytab and would limit the enctypes negotiated for the service.  After
the change, the service asserts enctypes based on the Kerberos
library's capabilities, not on what the service can actually handle.

> This seems to be exactly what the RFC's introduction
> (http://tools.ietf.org/html/rfc4537#section-1) explains, although it
> focusses on negotiating *stronger* encryption than what the KDC believes
> the service supports.
>
> So the proper workaround would be on the KDC by disabling all encryption
> types but Single DES for the service's principal. Since this is somewhat
> cumbersome in AD I instead just limited the client using the
> default_tkt_enctypes and permitted_enctypes options.
>
> The main problem I have with that, is that this degrades the encryption
> type of the tickets as well. I know of no option to tell an MIT or AD KDC
> to just limit the session key enctype to Single DES but encrypt the ticket
> with AES256. So to keep my NFSv4 setup working with the newer version of
> nfs-utils I actually have to make it even less secure.
>
> Another possible workaround would be just setting permitted_enctypes =
> des-cbc-md5 on the client and with perhaps a custom krb5.conf just for
> nfs-utils. But in my tests, setting just permitted_enctypes and no
> default_tkt_enctypes had no effect. This might be some AD speciality,
> though, that I haven't tracked down yet.
>
>> A proper fix needs to be on the server.  (Remember that non-Linux
>> clients may be trying to use that RHEL5 server, and have no such
>> mechanism to limit the requested enctypes.)
>
> I would agree, if it could be done without subkey negotiation. Please tell
> me, I'm wrong.
>
>> AFAIK, the only way to properly "fix" the issue is at the server by
>> adding "permitted_enctypes = des-cbc-md5" in krb5.conf.  This does
>> have the downside of limiting all services to DES, as you've stated.
>
> Because the server has no way of telling the client of this limitation,
> the client will still obtain e.g. an arcfour ticket with arcfour session
> key inside and present it to the server. Instead of the kernel saying
> "gss_kerberos_mech: unsupported algorithm 23" svcgssd will say "Encryption
> type not permitted" (or suchlike). The mount will still fail. Or not? It's
> my experience so far, at least, and corresponds to my knowledge of how
> Kerberos works.
>
>> I don't know if patches for Kerberos and nfs-utils could be pulled up
>> to RHEL5.  IMHO, that would be the ideal solution.
>
> Yeah, that would be great. But I suspect, RFC4537-support from
> mit-krb5-1.9 is somewhat more than a houndret lines of code and not very
> backport-friendly. Also, this would need to be done in every Linux
> distribution for all sorts of combinations of nfs-utils and mit-krb5. A
> nice self-contained patch to nfs-utils or even just some
> krb5.conf-[appdefaults]-magic seems a lot more friendly to me.

The Kerberos changes to allow the server side to limit the the
negotiated enctypes are not that extensive.  The nfs-utils changes may
be more than they are willing to include.

> I wonder whether the client could securely apply a heuristic encryption
> type detection: First it would try the strongest available encryption
> type. If that didn't work, it'd try the next and so on down to Single DES
> (if permitted in /etc/krb5.conf). But apart from the performance impact I
> see the problem of an attacker interfering with the first few packets of a
> mount to degrade authentication and encryption of a connection from aes256
> to des-cbc-crc.
>
> Thanks,
> Micha

I don't object to your change, but will assert that your suggested
solution does not handle non-Linux clients attempting to use the RHEL5
server.

K.C.
