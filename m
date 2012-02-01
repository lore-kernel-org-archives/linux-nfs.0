Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tango.0pointer.de ([85.214.72.216]:57196 "EHLO
	tango.0pointer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756078Ab2BAVwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 16:52:50 -0500
Date: Wed, 1 Feb 2012 22:45:36 +0100
From: Lennart Poettering <lennart@poettering.net>
To: Tom Gundersen <teg@jklm.no>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Message-ID: <20120201214536.GL18571@tango.0pointer.de>
References: <1324602327-1789-1-git-send-email-teg@jklm.no>
 <1328096830-1383-1-git-send-email-teg@jklm.no>
 <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com>
 <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 01.02.12 17:37, Tom Gundersen (teg@jklm.no) wrote:

> >> +     /* Try to find if one of the systemd sockets we were given match
> >> +      * our netconfig structure. */
> >> +
> >> +     for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++) {
> >> +             struct __rpc_sockinfo si_other;
> >> +             union {
> >> +                     struct sockaddr sa;
> >> +                     struct sockaddr_un un;
> >> +                     struct sockaddr_in in4;
> >> +                     struct sockaddr_in6 in6;
> >> +                     struct sockaddr_storage storage;
> >> +             } sa;
> >
> > Why is sockaddr_storage included in this union?
> 
> This is from Lennart's original patch. Lennart, care to comment?

Well, simply because sockaddr_storage is the actual struct one should
normally use for this kind of thing (where you try to determine a
sockaddr from a socket you don't know at all). With one exception
however, sockaddr_un is actually longer than sockaddr_storage, which is
documented borkedness in the socket API.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
