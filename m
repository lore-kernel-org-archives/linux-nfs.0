Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcbhh.dreamhost.com ([208.97.132.177]:56014 "EHLO
	homiemail-a16.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751806Ab1KDOvW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 10:51:22 -0400
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a16.g.dreamhost.com (Postfix) with ESMTPSA id 8E15850807C
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 07:51:21 -0700 (PDT)
Received: by vws1 with SMTP id 1so1947853vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 07:51:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320356806.18396.149.camel@lade.trondhjem.org>
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
Date: Fri, 4 Nov 2011 09:51:20 -0500
Message-ID: <CAK3OfOgPaXfrSkf6GtBNX3Gw3+mr1h+dNEuBMpGKL4ok=QLBUQ@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 3, 2011 at 4:46 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-11-03 at 17:30 -0400, Simo Sorce wrote:
>> I have discussed use of the keyring in a private discussion before
>> starting the thread, and it turns out the keyring has a number of
>> limitations that makes it probably unsuitable for this project.
>>
>> As an upcall mechanism it has some limitations on the size of the
>> payloads, IIRC limited to a page, and that means that you cannot pass
>> blobs carrying big kerberos tickets.

I never meant storing the ccache, or even the TGTs in the keyring.

>> As a storage mechanism for credential caches it also has size limits.
>> Currently the limit is 20k per user which is not even enough to hold a
>> single ticket in some cases. This limit can be increased of course, but
>> then you end keeping around a huge amount of unswappable ram depending
>> on the number of users.
>
> Allowing keys to be swapped out is a really really really really really
> really bad idea when your kernel depends upon them being available as
> part of the memory reclaim process, as would be the case when you are
> talking about NFS, CIFS or AFS dirty page writebacks.

If you have local swap you'll be fine.  Of course, the text for the
gssd had better be in-core.  Diskless over NFS doesn't work all that
well, IMO.

Obviously you'll need to be able to block the triggering
process/syscall, and you'll need to make sure there's no deadlock, but
the first is a given (since we're talking about NFS) and the second
should be possible if gssd does not stray into any NFS mounts (see my
comment about disklessness over NFS).

But even if you want diskless over NFS with RPCSEC_GSS (you'll want
RPCSEC_GSSv3) you can make this work by ensuring that all of the text
of gssd and its libraries and plugins and... are pinned in-core, and
by not swapping over NFS.  The way Linux boot works this is quite
feasible.  You'll want ccaches stored in tmpfs, of course.

>> So for long term storage of credentials we will probably not rely on
>> kernel keyrings, nor as an upcall mechanism.
>
> So this would be an argument for scrapping keyrings from the kernel? If
> they're not good for kerberos tickets, why would we want to keep them at
> all?
> What would you replace them with, given the above requirements
> concerning swapping?

No, I don't think it's an argument for scrapping keyrings, just for
not storing actual credentials in them (store references to them
instead).

I like to think that my CPG proposal for Solaris from a few years ago
is much cleaner than keyrings.  But keyrings could be made to do.

Nico
--
