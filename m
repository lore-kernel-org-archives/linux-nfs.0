Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34197 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcCWEUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2016 00:20:12 -0400
MIME-Version: 1.0
In-Reply-To: <CAH2r5mtoYNrjkJ+zCbx7Mif9d-+-P_uBmdQNDwLA57wW6t7L6Q@mail.gmail.com>
References: <56F03945.40208@gentoo.org> <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org> <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org> <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
 <56F0AC2A.30300@gentoo.org> <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
 <20160322200801.GF4083@fieldses.org> <20160322214255.GA10921@jra3> <CAH2r5mtoYNrjkJ+zCbx7Mif9d-+-P_uBmdQNDwLA57wW6t7L6Q@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Tue, 22 Mar 2016 23:19:51 -0500
Message-ID: <CAH2r5murJ73bfoHWGTDPOBxud3E+rdzW00Snn-TZuc-iEtWgrw@mail.gmail.com>
Subject: Re: Making an interface for alternative data streams
To: Jeremy Allison <jra@samba.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Richard Sharpe <realrichardsharpe@gmail.com>,
        Richard Yao <ryao@gentoo.org>,
        Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 11:13 PM, Steve French <smfrench@gmail.com> wrote:
> On Tue, Mar 22, 2016 at 4:42 PM, Jeremy Allison <jra@samba.org> wrote:
>> On Tue, Mar 22, 2016 at 04:08:01PM -0400, J. Bruce Fields wrote:
>>>
>>> But you do see people using "named attributes"/"alternative data
>>> streams"?
>>>
>>> This comes up at the LSF/MM summit every now and then and Jeremy Allison
>>> inevitably says "hah, only malware writers use those", and that's the
>>> end of the discussion.  Sounds like Richard Yao has heard otherwise, but
>>> it'd be nice to have actual examples of users.
>>
>> The only use I know of other than malware writers is
>> the :Zone.Identifier stream used by Internet Explorer.
>>
>> http://woshub.com/how-windows-determines-that-the-file-has-been-downloaded-from-the-internet/
>>
>> Not sure if the new Microsoft browser still uses them
>> (I haven't used desktop Windows in over 10 years).
>
> Yes, the browser still uses it (at least on the system I tried
> yesterday), and so do a few important subsystems (the file resource
> manager for example).  Presumably streams are used even more on Mac.
>
> I was experimenting with some patches in the last few weeks to list
> streams (either via an xattr as ntfs-3g does, but I am leaning toward
> an ioctl for cifs.ko).  They are needed for backup (at least), and not
> just for accessing Macs (which use resource forks extensively), but
> since Windows stores the zone identifier (where a file came from is
> stored when internet explorer downloads anything) in an alternate data
> stream, and also "FCI" (file classification information) is stored
> there.

I should also note that since SMB3 operations are handle based
(except open/create itself), I prefer using an ioctl rather than xattr
query to list streams.  In addition, by overlapping the alternate
data stream name space, with the EAs name space they are
harder to tell apart (xattrs are used less frequently on Windows
than in the past but they do show up from time to time,
e.g. in their Services for Unix).  Seems wrong to make it easy
to confuse streams and EAs (extended attributes).


-- 
Thanks,

Steve
