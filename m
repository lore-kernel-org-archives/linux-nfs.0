Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56717 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878Ab0HFDzI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 23:55:08 -0400
In-Reply-To: <20100806133836.49757af9@notabene>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1280524978.2452.9.camel@segv.aura.of.mankind>
	<20100801092529.5e6ba0e0@corrin.poochiereds.net>
	<20100805235218.GB31233@jeremy-laptop>
	<20100806133836.49757af9@notabene>
Date: Thu, 5 Aug 2010 22:55:06 -0500
Message-ID: <AANLkTinVCLVpqLtA2X=1mOkxX7Re61_ZYsUix_XTvZ5D@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
From: Steve French <smfrench@gmail.com>
To: Neil Brown <neilb@suse.de>
Cc: Jeremy Allison <jra@samba.org>, Jeff Layton <jlayton@redhat.com>,
        utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 5, 2010 at 10:38 PM, Neil Brown <neilb@suse.de> wrote:
> On Thu, 5 Aug 2010 16:52:18 -0700
> Jeremy Allison <jra@samba.org> wrote:

>> Don't add it as an EA. It's *not* an EA, it's a timestamp.
>
> I'm curious.  Why do you particularly care what interface the kernel uses to
> provide you with access to this attribute?
>
> And given that it is an attribute that is not part of 'POSIX' or "UNIX", it
> would seem to be an extension - an extended attribute.
> As the Linux kernel does virtually nothing with this attribute except provide
> access, it seems to be a very different class of thing to other timestamps.
> Surely it is simply some storage associated with a file which is capable of
> storing a timestamp, which can be set or retrieved by an application, and
> which happens to be initialised to the current time when a file is created.
>
> Yes, to you it is a timestamp.  But to Linux it is a few bytes of
> user-settable metadata.  Sounds like an EA to me.
>
> Or do you really want something like BSD's 'btime' which as I understand it
> cannot be set.  Would that be really useful to you?

Obviously the cifs and SMB2 protocols which  Samba server support can
ask the server to set the create time of a file (this is handled
through xattrs today along with the "dos attribute" flags such as
archive/hidden/system), but certainly it is much more common (and
important) to read the creation time of an existing file.


> Is there something important that I am missing?

It is another syscall that Samba server would have to make - and xattr
performance is extremely slow on some file systems (although
presumably this one would be more likely to be stored in inode and
perhaps not as bad on ext4, cifs and a few others such as ntfs).


-- 
Thanks,

Steve
