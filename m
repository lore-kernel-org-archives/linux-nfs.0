Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933589Ab0GOVxg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 17:53:36 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <201007152235.22373.arnd@arndb.de>
References: <201007152235.22373.arnd@arndb.de> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
To: Arnd Bergmann <arnd@arndb.de>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Thu, 15 Jul 2010 22:53:27 +0100
Message-ID: <30646.1279230807@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Arnd Bergmann <arnd@arndb.de> wrote:

> > This was initially proposed as a set of xattrs, but the general preferance
> > is for an extended stat structure.
> 
> I don't think I'd call this general preference. Three of the four
> are fixed length and could easily be done inside the structure if you
> leave a bit of space instead of a variable-length field at the end.

?

Maybe I wasn't clear: I meant having an extended stat() syscall rather than
using a bunch of getxattr()'s was the general preference.

> For the volume id, I could not find any file system that requires more
> than 32 bytes here, which is also reasonable to put into the structure.
> Make it 36 if you want to cover ascii encoded UUIDs.

You should also include a length.  Volume IDs may be binary rather than
NUL-terminated strings.

> That's at most 60 bytes for the extensions you're considering already,
> plus the 152

160, I think.

> you have already is still less than a cache line on
> some machines. Padding it to 256 bytes would make it nice and round,
> if you want to be really sure, make it 384 bytes.

Which we currently allocate on the kernel stack, plus up to a couple of kstat
structs if something like eCryptFS is used.  Admittedly, the base xstat struct
could be kmalloc()'d instead, but why use up all that space if you don't need
it?

David
