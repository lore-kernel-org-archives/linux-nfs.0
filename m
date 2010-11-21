Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:50889 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab0KUTbs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Nov 2010 14:31:48 -0500
Received: by ewy5 with SMTP id 5so1327211ewy.19
        for <linux-nfs@vger.kernel.org>; Sun, 21 Nov 2010 11:31:47 -0800 (PST)
In-Reply-To: <20101121104624.GA13874@infradead.org>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
	<1290194699.3135.49.camel@heimdal.trondhjem.org>
	<20101119200421.GA3143@fieldses.org>
	<1290201995.3135.63.camel@heimdal.trondhjem.org>
	<20101121104624.GA13874@infradead.org>
Date: Sun, 21 Nov 2010 11:31:47 -0800
Message-ID: <AANLkTim3dhYiEnJNW8Q7XM0MgF=AVjRDU6W5vVas8vPU@mail.gmail.com>
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Moazam Raja <moazam@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is my understanding as well, at least from reading the man pages.
O_DIRECT and O_SYNC have different characteristics, so I'm a bit
surprised at the responses here.

Furthermore, using O_DIRECT over a 1Gbe connection yields 100-110MB/s
performance where as O_SYNC on the same connection gives me around
20-30MB/s at best. There is definitely a difference.

-Moazam


On Sun, Nov 21, 2010 at 2:46 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Nov 19, 2010 at 04:26:35PM -0500, Trond Myklebust wrote:
>> If the application requests O_DIRECT/O_SYNC or calls fsync(), we are
>> required by POSIX to ensure the data is safe on disk. The presence of an
>> NFS delegation does not change that requirement.
>
> That's not quite correct.  O_DIRECT for one is not actually specific in
> Posix at all, and the documented Linux semantics only say that the
> pagecache should not be used (even if it sometimes is with various
> filesystems).  There is not guarantee that data actually is on disk or
> reachable, for that you need to add the O_SYNC/O_DYSNC flag in addition
> or use fsync/fdatasync.
>
>
