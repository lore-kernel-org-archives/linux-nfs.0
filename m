Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34734 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbcEMO2a convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2016 10:28:30 -0400
MIME-Version: 1.0
In-Reply-To: <4211584.odaTcq8sN6@wuerfel>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
	<CAH2r5mvWHwmqkzyfjHro__dWf-9ZAskPHgHDGS22jNzXZVQ4iA@mail.gmail.com>
	<CAH2r5muL336k178DJHxKByfbGMMc=_m5jsCctgRQCc1H+SRSQg@mail.gmail.com>
	<4211584.odaTcq8sN6@wuerfel>
Date: Fri, 13 May 2016 07:28:29 -0700
Message-ID: <CACyXjPw-dY4o4O_ZXzeb9R-akmE-r1uAQ7Sd-dGYegkG932yqw@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
From: Richard Sharpe <realrichardsharpe@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Steve French <smfrench@gmail.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 9, 2016 at 6:09 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thursday 05 May 2016 21:00:18 Steve French wrote:
>> On Thu, May 5, 2016 at 5:54 PM, Steve French <smfrench@gmail.com> wrote:
>> > On Wed, May 4, 2016 at 8:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> >> On Friday 29 April 2016 13:57:36 David Howells wrote:
>> >>> struct statx *buffer);
>> >>>
>> >>> This is an enhanced file stat function that provides a number of useful
>> >>> features, in summary:
>> >>>
>> >>> (1) More information: creation time, data version number, inode
>> >>> generation
>> >>> number and flags. A subset of these is available through a number of
>> >>> filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
>> >>>
>> >>
>> >> I have a question about birthtime/creationtime: As we are gaining a way
>> >> to read this, should we also provide a way to update it using a new
>> >> variant
>> >> of the utimensat syscall in order to have 'cp -a' create an identical
>> >> copy,
>> >> or is the idea that this is defined as the time that is particular copy
>> >> of the inode was created?
>> >>
>> >> I've discussed this with Deepa in the past, as she is driving the
>> >> convertion of the inode timestamps to timespec64 now, and we will
>> >> need a new version of utimensat for her work as well. I can see good
>> >> reasons either way (allowing updates of btime or disallowing them).
>> >
>> It would help interop with Windows (and presumably Mac) if birth time can be
>> updated
>
> Ok, thanks. That is certainly a good reason in favor.
>
> If nothing else comes up, I guess we can prepare a patch for a new
> utimensat variant to do this and wait for more comments on that.
>
>         Arnd

Isn't there also a strong case for a setattr call that allows us to
atomically set a collection of attributes from userspace?

It would seem that network file systems (the clients) could use such features.

-- 
Regards,
Richard Sharpe
(何以解憂？唯有杜康。--曹操)
