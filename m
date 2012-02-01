Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:32479 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983Ab2BAWDz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 17:03:55 -0500
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120201214536.GL18571@tango.0pointer.de>
Date: Wed, 1 Feb 2012 17:03:38 -0500
Cc: Tom Gundersen <teg@jklm.no>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Message-Id: <5748CC59-354A-4D97-AF0C-224975BCA253@oracle.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no> <1328096830-1383-1-git-send-email-teg@jklm.no> <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com> <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com> <20120201214536.GL18571@tango.0pointer.de>
To: Lennart Poettering <lennart@poettering.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 1, 2012, at 4:45 PM, Lennart Poettering wrote:

> On Wed, 01.02.12 17:37, Tom Gundersen (teg@jklm.no) wrote:
> 
>>>> +     /* Try to find if one of the systemd sockets we were given match
>>>> +      * our netconfig structure. */
>>>> +
>>>> +     for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++) {
>>>> +             struct __rpc_sockinfo si_other;
>>>> +             union {
>>>> +                     struct sockaddr sa;
>>>> +                     struct sockaddr_un un;
>>>> +                     struct sockaddr_in in4;
>>>> +                     struct sockaddr_in6 in6;
>>>> +                     struct sockaddr_storage storage;
>>>> +             } sa;
>>> 
>>> Why is sockaddr_storage included in this union?
>> 
>> This is from Lennart's original patch. Lennart, care to comment?
> 
> Well, simply because sockaddr_storage is the actual struct one should
> normally use for this kind of thing (where you try to determine a
> sockaddr from a socket you don't know at all). With one exception
> however, sockaddr_un is actually longer than sockaddr_storage, which is
> documented borkedness in the socket API.

You don't reference any of the fields inside this union, except for sa.  It seems unnecessary to include all of these members, and then not use most of them.

The biggest address you're ever going to get out of libtirpc is a sockaddr_storage.  If we must stick with a union to prevent pointer aliasing, can we have just two members: sockaddr and sockaddr_storage?

Otherwise, there's no need for this kind of generality here:  TI-RPC handles only IPv4, IPv6, and AF_LOCAL.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




