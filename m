Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33371 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbbKJR6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2015 12:58:22 -0500
Received: by lbbkw15 with SMTP id kw15so2851349lbb.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2015 09:58:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151110170703.GB17530@fieldses.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
	<20151110112943.GA17038@infradead.org>
	<CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
	<CAH2r5ms1ckC59o9sbBEBAWQA0Q3tGOs=YJpk01xg19zThJDt-w@mail.gmail.com>
	<20151110170703.GB17530@fieldses.org>
Date: Tue, 10 Nov 2015 18:58:19 +0100
Message-ID: <CAHc6FU6aWsWO1SOSyNVnbObE0GoE4dr5a3WVTgvX4xn0wum1Fg@mail.gmail.com>
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve French <smfrench@gmail.com>, Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 6:07 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Nov 10, 2015 at 10:43:46AM -0600, Steve French wrote:
>> On Tue, Nov 10, 2015 at 6:39 AM, Andreas Gruenbacher
>> <agruenba@redhat.com> wrote:
>> > On Tue, Nov 10, 2015 at 12:29 PM, Christoph Hellwig <hch@infradead.org> wrote:
>> >> On Mon, Nov 09, 2015 at 12:08:41PM +0100, Andreas Gruenbacher wrote:
>> >>> Here is another update to the richacl patch queue.  This posting contains
>> >>> the patches ready to be merged; the patches later in the queue still need
>> >>> some more review.
>> <snip>
>> >> and still abuses xattrs instead of a proper syscall interface.
>> >> That's far from being ready to merge.
>> >
>> > The xattr syscall interface is what's used for very similar kinds of
>> > things today; using it for richacls as well sure does not count as
>> > abuse. Things could be improved in the xattr interface and in its
>> > implementation, but we need more substantial reasons than that for
>> > reimplementing the wheel once again.
>>
>> I don't have strong disagreement with using pseudo-xattrs to
>> store/retrieve ACLs (we already do this) but retrieving/setting an ACL
>> all at once can be awkward  when ACLs are quite large e.g. when it
>> encodes to over 1MB
>
> At least in the NFS case, that's also a limitation of the protocol.

I couldn't find a limit in the NFSv4 specification, but the client and
server implementations both define arbitrary ACL size limits. In
addition, the xattr syscalls allow attributes to be up to 64k long.

> If
> we really wanted to support massive ACLs then we'd need both syscall and
> NFS interfaces to allow incrementally reading and writing ACLs, and I
> don't even know what those would look like.
>
> So this is a fine limitation as far as I'm concerned.

The bigger problem would be incrementally setting ACLs. To prevent
processes from racing with each other, we would need a locking
mechanism. In addition, the memory overhead would be prohibitive and
access decisions would become extremely slow; we would have to come up
with mechanisms to avoid those problems.

Thanks,
Andreas
