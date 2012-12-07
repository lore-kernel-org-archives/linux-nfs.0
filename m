Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.etersoft.ru ([87.249.47.46]:54532 "EHLO mail.etersoft.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424343Ab2LGUw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 15:52:58 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Sat, 08 Dec 2012 00:43:14 +0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Christoph Hellwig <hch@infradead.org>
Cc: <linux-cifs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <wine-devel@winehq.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Add =?UTF-8?Q?O=5FDENY*=20flags=20to=20fcntl=20an?=
 =?UTF-8?Q?d=20cifs?=
In-Reply-To: <20121207161602.GA17710@infradead.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121207161602.GA17710@infradead.org>
Message-ID: <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig писал 07.12.2012 20:16:
> On Thu, Dec 06, 2012 at 10:26:28PM +0400, Pavel Shilovsky wrote:
>> Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - 
>> this change can benefit cifs and nfs modules. While this change is ok 
>> for network filesystems, itsn't not targeted for local filesystems due 
>> security problems (e.g. when a user process can deny root to delete a 
>> file).
>>
>> Share flags are used by Windows applications and WINE have to deal 
>> with them too. While WINE can process open share flags itself on local 
>> filesystems, it can't do it if a file stored on a network share and is 
>> used by several clients. This patchset makes it possible for 
>> CIFS/SMB2.0/SMB3.0.
>
> I don't think introducing user visible flags that are only supported 
> on
> a single network filesystem is a good idea.

It can bring benefits for both CIFS and NFS filesystems - so, at least 
two ones.

>
> I'm not even sure adding these flags does make a lot of sense, but
> assuming we'd actually want this (and I'd like some more detailed
> explanation) I think we'd at least need to make sure that:
>
>  a) opening files with the new modes gives a proper error message if 
> not
>     supported

It makes us add such checks for all other filesystems, if I understand 
right, - not a problem, I think.

>  b) there needs to be local support for them as well
>  c) we need to think really hard when they should be supported, and 
> need
>     a good rational for it.  I can't see how we could do it
>     unconditionally for all users as that would introduce easy denial
>     of services attacks the way I understand the semantics (correct 
> me
>     if I'm wrong).  So a mount option like you currently do probably 
> is
>     the least bad even if don't fell overly happy about that version.
>
> What is the reason your special wine use case can't simply use a
> userspace cifs client?  Given that wine uses windows filesystem
> semantics and cifs does as well tunnelling it through a Posix-like 
> API
> inbetween is never going to be perfect.

Ideally we should not make any difference between underlying 
filesystems in Wine: an application requests an open of the file and we 
issue this open with flags it passed. Since Wineserver can process share 
flags locally itself (for one linux user), we only need to add this 
support for CIFS (that is actively used by Wine applications because of 
it's Windows nature). Bringing these flags for local filesystems can 
benefit Wine too: it will help in cases when Wine applications of 
different users on the same machine use the same file and can make all 
those things easier, of course.

The problem is the possibility of denial-of-service attacks here. We 
can try to prevent them by:
1) specifying an extra security bit on the file that indicates that 
share flags are accepted (like we have for mandatory locks now) and 
setting it for neccessary files only, or
2) adding a special mount option (but it it probably makes sense if we 
decided to add this support for CIFS and NFS only).

--
Best regards,
Pavel Shilovsky.


