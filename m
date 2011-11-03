Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailbigip.dreamhost.com ([208.97.132.5]:37953 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751230Ab1KCUx1 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 16:53:27 -0400
Received: from homiemail-a36.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a36.g.dreamhost.com (Postfix) with ESMTP id 59E57778071
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 13:53:19 -0700 (PDT)
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a36.g.dreamhost.com (Postfix) with ESMTPSA id A4CDC778061
	for <linux-nfs@vger.kernel.org>; Thu,  3 Nov 2011 13:53:16 -0700 (PDT)
Received: by vws1 with SMTP id 1so1309047vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 03 Nov 2011 13:53:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320352784.18396.109.camel@lade.trondhjem.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
	<CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	<1320337903.7734.670.camel@willson.li.ssimo.org>
	<CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	<1320352784.18396.109.camel@lade.trondhjem.org>
Date: Thu, 3 Nov 2011 15:53:12 -0500
Message-ID: <CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, linux-nfs@vger.kernel.org,
        krbdev <krbdev@mit.edu>, dhowells <dhowells@redhat.com>,
        =?UTF-8?B?TG92ZSBIw7ZybnF1aXN0IMOFc3RyYW5k?= <lha@kth.se>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 3, 2011 at 3:39 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>> What I had in mind was something like PAGs or keyrings.  Or, to be
>> much more specific, search for my name and the string "credentials
>> process groups" -- a PAG on steroids.
>>
>> The idea is that the IPC peer can observe the other's
>> PAG/keyring/CPG/whatever and use that to find the correct credentials
>> (authorization is still required though).
>
> Linux already has per-user, per-process and per-thread keyrings which
> offer a high security storage solution for keys. The problem with those
> is that they are difficult to use in an asynchronous context when the
> original user's process/thread context is no longer available to us.

For async IPC methods you'd want something like SCM_CREDENTIALS to
give you the keyring/PAG/whatever information you need abou thte peer.
 The ancillary data should be complete enough that you can past the
client process/thread being dead, although it's nice to not have to
process a request from a dead entity...

For sync IPC you need something like door_ucred().  And for sync IPC
you can make sure to get SIGCANCEL or equivalent when the client gets
canceled (this is the default in doors).

> Ideally, though, that's what we'd like to see used.

Agreed!

Nico
--
