Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33644 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755816AbcEFCAj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 22:00:39 -0400
MIME-Version: 1.0
In-Reply-To: <CAH2r5mvWHwmqkzyfjHro__dWf-9ZAskPHgHDGS22jNzXZVQ4iA@mail.gmail.com>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <5680195.kS2oylQXhI@wuerfel> <CAH2r5mvWHwmqkzyfjHro__dWf-9ZAskPHgHDGS22jNzXZVQ4iA@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Thu, 5 May 2016 21:00:18 -0500
Message-ID: <CAH2r5muL336k178DJHxKByfbGMMc=_m5jsCctgRQCc1H+SRSQg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Howells <dhowells@redhat.com>,
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

On Thu, May 5, 2016 at 5:54 PM, Steve French <smfrench@gmail.com> wrote:
> On Wed, May 4, 2016 at 8:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Friday 29 April 2016 13:57:36 David Howells wrote:
>>> struct statx *buffer);
>>>
>>> This is an enhanced file stat function that provides a number of useful
>>> features, in summary:
>>>
>>> (1) More information: creation time, data version number, inode
>>> generation
>>> number and flags. A subset of these is available through a number of
>>> filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
>>>
>>
>> I have a question about birthtime/creationtime: As we are gaining a way
>> to read this, should we also provide a way to update it using a new
>> variant
>> of the utimensat syscall in order to have 'cp -a' create an identical
>> copy,
>> or is the idea that this is defined as the time that is particular copy
>> of the inode was created?
>>
>> I've discussed this with Deepa in the past, as she is driving the
>> convertion of the inode timestamps to timespec64 now, and we will
>> need a new version of utimensat for her work as well. I can see good
>> reasons either way (allowing updates of btime or disallowing them).
>
It would help interop with Windows (and presumably Mac) if birth time can be
updated



-- 
Thanks,

Steve
