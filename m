Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35453 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbJFUzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 16:55:21 -0400
MIME-Version: 1.0
In-Reply-To: <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
 <20151004062313.GA20212@infradead.org> <CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
 <5612C85C.2060407@gmail.com> <20151006094935.GA14144@infradead.org>
 <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com> <CF738526-0807-4CE5-A52B-413164D41AA9@dilger.ca>
From: Steve French <smfrench@gmail.com>
Date: Tue, 6 Oct 2015 15:55:01 -0500
Message-ID: <CAH2r5mtbg7QQVQsi_7RDF855dkqumX1K2thCyBirqn=uCRZa8A@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
To: Andreas Dilger <adilger@dilger.ca>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 6, 2015 at 3:26 PM, Andreas Dilger <adilger@dilger.ca> wrote:
> On Oct 6, 2015, at 7:12 AM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
>>
>> On Tue, Oct 6, 2015 at 11:49 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>> On Mon, Oct 05, 2015 at 02:58:36PM -0400, Austin S Hemmelgarn wrote:
>>>> I think the point is that a new VFS feature that is easy to integrate in
>>>> multiple filesystems should have support for those filesystems.  A decade
>>>> ago, just having ext* support would probably have been fine, but these days,
>>>> XFS, BTRFS, and F2FS are used just as much (if not more) on production
>>>> systems as ext4, and having support for them right from the start would
>>>> significantly help with adoption of richacls.
>>>
>>> That's one reason.  The other is that actually wiring it up for more
>>> than a single consumer shows its actually reasonable generic.
>>
>> The filesystem interface now is the same as for POSIX ACLs, used by a
>> dozen or so filesystems already.
>>
>>> I don't want to end up with a situration like Posix ACLs again where
>>> different file systems using different on disk formats again.
>>
>> Any file system could choose a different on-disk format than the one
>> that ext4 currently uses, but I don't see a reason why any should.
>> Apart from uid / gid mappings that is the same as the user-space xattr
>> format. Network file systems like NFSv4 and CIFS with their predefined
>> over-the-wire formats obviously are another story.
>
> And any disk filesystems that have their own non-POSIX ACLs, such as HFS, NTFS, ZFS would presumably also need to map the in-kernel Richacl format to their on-disk format.

Will be interesting to see whether in the long run can have some
common code in NTFS, CIFS/SMB3 (and even NFSv4.x) ACL parsing since
their formats are quite closely related



-- 
Thanks,

Steve
