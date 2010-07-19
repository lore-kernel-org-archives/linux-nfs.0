Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58344 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932452Ab0GSRrd convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 13:47:33 -0400
In-Reply-To: <11817.1279560400@redhat.com>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<AANLkTikuzYqYpGHcubb7QVciZW0dNFjOG82qIwy5M4gO@mail.gmail.com>
	<10783.1279556132@redhat.com>
	<AANLkTinVns77R7yCCh-lydd0eQufdAF9O2OaWmCL7uSn@mail.gmail.com>
	<11817.1279560400@redhat.com>
Date: Mon, 19 Jul 2010 10:46:55 -0700
Message-ID: <AANLkTikxHJgguNn6EOK6fX53xYSRPmcNjIeGSTigQ9qu@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
From: Linus Torvalds <torvalds@linux-foundation.org>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 19, 2010 at 10:26 AM, David Howells <dhowells@redhat.com> wrote:
>
>> Ask your samba people, for example, if they'd _ever_ do just a "xstat()"?
>
> I suspect they would, though maybe they can say otherwise.  What about SMB
> directory enumeration?  I believe that is effectively getdents-with-stat.
> Having to do open+stat for each file for that would be painful.

Yeah, but do you need xstat information at all for something like
that? Most people try very hard to make do with the information
returned by readdir itself (d_type and inode number), because if you
end up looking up each name you've already pretty much lost in a
performance model.

(And I do agree that a "readdirplus()" is probably something that a
lot of server people would find useful, but obviously that's another
cross-filesystem nightmare. Only a few filesystems can cheaply give
you anything but d_type/d_ino, and not all do even that),

                      Linus
