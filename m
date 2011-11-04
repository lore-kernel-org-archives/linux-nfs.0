Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcagg.dreamhost.com ([208.97.132.66]:59381 "EHLO
	homiemail-a34.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754667Ab1KDPNk convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 11:13:40 -0400
Received: from homiemail-a34.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a34.g.dreamhost.com (Postfix) with ESMTP id 557AA10062
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 08:13:40 -0700 (PDT)
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a34.g.dreamhost.com (Postfix) with ESMTPSA id BB2101005D
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 08:13:39 -0700 (PDT)
Received: by vws1 with SMTP id 1so1970656vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 08:13:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA90EE@SACMVEXC2-PRD.hq.netapp.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
	<CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	<1320337903.7734.670.camel@willson.li.ssimo.org>
	<CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	<1320352784.18396.109.camel@lade.trondhjem.org>
	<CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
	<1320355818.7734.685.camel@willson.li.ssimo.org>
	<1320356806.18396.149.camel@lade.trondhjem.org>
	<1320357606.7734.697.camel@willson.li.ssimo.org>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA90EE@SACMVEXC2-PRD.hq.netapp.com>
Date: Fri, 4 Nov 2011 10:13:38 -0500
Message-ID: <CAK3OfOjqCjU4O--XwVBpSBE9pwwkyBEU6OiNLN8_dM6wYe5A1w@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 3, 2011 at 5:16 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> It is ok to use keyring if that's deemed the right place for session keys, but I
>> think you already have structures where you currently store them so I don't
>> thik you necessarily need to change that part of the kernel implementation.
>
> No, but we still need to be able to do recovery of rpcsec_gss contexts once they are broken, and right now we have a major flaw due to the fact that recovery depends on a lot of small processes and data that is allowed to be swapped out at the moment when we need them the most (i.e. in a memory reclaim situation).
>
> If the server reboots while our client is in the middle of writing back a file (or several files), then the client needs to recover those rpcsec_gss contexts that authenticate the processes which own any dirty pages that remain to be written out.
> Key security is an irrelevant concern once your kernel deadlocks in an OOM state.

Ah, this problem.  Hopefully the client has enough resources to thrash
a lot in the process but still manage to recover.  A better solution
(see below) is possible, but will require more protocol/mechanism
work.

>> Currently credential caches are stored in files, is there a problem with that
>> model ? Do you need access to credential caches from the kernel when
>> under memory pressure ?
>
> Yes, there is a major problem with that model, and yes we do potentially need access to credential caches when in a recovery situation (which is a situation when we are usually under memory pressure).

Ideally we could store in each RPCSEC_GSS context (not GSS context)
enough state on the client side to recover quickly when the server
reboots.  How would we do this?  Suppose the server gives the client a
"ticket", and a key much like the Kerberos ticket session key is
agreed upon or sent by the server -- that could be stored in the
RPCSEC_GSS context and could be used to recover it quickly for
recovery from server reboot.  I'm eliding a lot of details here, but I
believe this is fundamentally workable.

A similar solution would be to store some GSS "sub-credential" in the
RPCSEC_GSS context, but this would work for Kerberos and maybe not so
well for other mechanisms -- and even with Kerberos, the service
ticket might be expired when it comes time to recover.  So I prefer
the RPCSEC_GSS-level solution I mentioned above.

If you agree with me on this then this sub-thread will be best moved
to the NFSv4 WG, particularly if we agree on a protocol-level
solution.

Nico
--
