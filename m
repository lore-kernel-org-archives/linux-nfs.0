From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Mon, 24 Aug 2009 08:11:33 -0400
Message-ID: <1251115893.6325.23.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:51164 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbZHXMLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 08:11:35 -0400
In-Reply-To: <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-24 at 12:32 +0200, Stefan Egli wrote:
> Hi,
> 
> It's me again. I'm catching up on 'man 5 nfs' and reading all the input I found
> wrt the NFS directory cache issue so far. So this is hopefully a condensed
> set of findings and questions ;)
> 
> 1) As I understand, the Linux version we're using (2.6.24-24-generic) does not
>    contain the patch 37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e51 - which
>    only made it to the kernel 2.6.30, right?

That would be a question for the Debian/Ubuntu maintainers. I have no
idea what they have included in 2.6.24-24-generic

> 2) I'm still not sure I understand that patch correctly though
>    (37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e5): Would the tivoli restore
>    be able to mess with mtimes and *therefore* cause the 4-5 hour cache
>    inconsistency I'm seeing? If yes, would the patch then magically fix this?

If tivoli is messing with the mtime, then it _might_ cause the
condition, in a restore situation by changing the directory contents but
not the mtime (which is what tells the NFS client and applications that
the directory contents have changed).
By looking at the ctime too, the client can always tell that something
has changed, and thus clear its cache.

> 3) The other part of my issue which I still don't understand is, why a backup
>    (not restore) could cause completely unrelated files (which we update every
>    5 minutes using some simple raw shell scripts) to remain out-of-sync
>    with other NFS clients - that is, client A changes the content every 5 min
>    but client B and C see it only after 1-2 hours. Seems somewhat new and
>    unrelated to the restore case of above - as restore does change directory
>    content (and that's where the problem lies) but backup merely changes
>    the file's mtime probably (but not even sure it does that - maybe leaves it
>    unchanged)

I've no idea why the other clients aren't seeing a change in this case.
I certainly cannot reproduce this with my own setup.

With the default acdirmin/max settings, the clients should not be
caching the mtime for longer than 1 minute. While they might be blind to
the directory changes during that time, they should at least see it
after the minute expires.

> 4) If I see this correctly, the acdirmin/acdirmax parameters could not prevent
>   a situation 2) of above?

No.

> 5) Would rdirplus be of any help here at all?

No.

> 6) Regarding the echo 3 > /proc/sys/vm/drop_caches issue:
> 
>   > Only if you are certain that there are no processes actually using that
>   > directory or any of its subdirs/files.
> 
>   What happens if there are processes still having files open in subdirs?
>   Would probably create .nfs files - but would it otherwise work - or corrupt
>   read/written data?

The VFS clears the cache by dropping unreferenced dentries. By holding a
reference to the directory or a subfile/subdir, your process would
simply cause the VFS to be unable to drop that dentry.

Cheers
  Trond

