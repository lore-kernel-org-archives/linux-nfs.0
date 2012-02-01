Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tango.0pointer.de ([85.214.72.216]:57510 "EHLO
	tango.0pointer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab2BAWab (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 17:30:31 -0500
Date: Wed, 1 Feb 2012 23:30:27 +0100
From: Lennart Poettering <lennart@poettering.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Tom Gundersen <teg@jklm.no>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Michal Schmidt <mschmidt@redhat.com>,
        Steve Dickson <steved@redhat.com>, systemd-devel@lists.freedesktop.org,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Message-ID: <20120201223027.GA29681@tango.0pointer.de>
References: <1324602327-1789-1-git-send-email-teg@jklm.no>
 <1328096830-1383-1-git-send-email-teg@jklm.no>
 <22B77A95-49D5-4855-A230-A86C57372B28@oracle.com>
 <CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
 <20120201214536.GL18571@tango.0pointer.de>
 <5748CC59-354A-4D97-AF0C-224975BCA253@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5748CC59-354A-4D97-AF0C-224975BCA253@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 01.02.12 17:03, Chuck Lever (chuck.lever@oracle.com) wrote:

> >>> Why is sockaddr_storage included in this union?
> >> 
> >> This is from Lennart's original patch. Lennart, care to comment?
> > 
> > Well, simply because sockaddr_storage is the actual struct one should
> > normally use for this kind of thing (where you try to determine a
> > sockaddr from a socket you don't know at all). With one exception
> > however, sockaddr_un is actually longer than sockaddr_storage, which is
> > documented borkedness in the socket API.
> 
> You don't reference any of the fields inside this union, except for sa.  It seems unnecessary to include all of these members, and then not use most of them.
> 
> The biggest address you're ever going to get out of libtirpc is a sockaddr_storage.  If we must stick with a union to prevent pointer aliasing, can we have just two members: sockaddr and sockaddr_storage?
> 
> Otherwise, there's no need for this kind of generality here:  TI-RPC handles only IPv4, IPv6, and AF_LOCAL.

Well, as said, sockaddr_un is actually larger than sockaddr_storage, and
hence you definitely do need sockaddr_un in the union. The IP cases are
covered by sockaddr_storage however, and hence can be left out of the
union.

I mean, it's completely up to you what is used here, I just figured the
point of the whole library was to be an exercise in keeping things
independent from the used socket family.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
