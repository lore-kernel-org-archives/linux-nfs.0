Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35702 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbJFNMi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 09:12:38 -0400
Received: by lbwr8 with SMTP id r8so75828590lbw.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 06:12:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151006094935.GA14144@infradead.org>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
	<20151004062313.GA20212@infradead.org>
	<CAHc6FU53mXg1k0KCNkWEjxyuC8iAUgWh-A76qX=C3Yth+qEyuQ@mail.gmail.com>
	<5612C85C.2060407@gmail.com>
	<20151006094935.GA14144@infradead.org>
Date: Tue, 6 Oct 2015 15:12:36 +0200
Message-ID: <CAHc6FU5aZJDC3N1iGyVeHfbqMyquM93ONJvUR-t0a9+AjmtAXQ@mail.gmail.com>
Subject: Re: [PATCH v8 00/41] Richacls
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 6, 2015 at 11:49 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Oct 05, 2015 at 02:58:36PM -0400, Austin S Hemmelgarn wrote:
>> I think the point is that a new VFS feature that is easy to integrate in
>> multiple filesystems should have support for those filesystems.  A decade
>> ago, just having ext* support would probably have been fine, but these days,
>> XFS, BTRFS, and F2FS are used just as much (if not more) on production
>> systems as ext4, and having support for them right from the start would
>> significantly help with adoption of richacls.
>
> That's one reason.  The other is that actually wiring it up for more
> than a single consumer shows its actually reasonable generic.

The filesystem interface now is the same as for POSIX ACLs, used by a
dozen or so filesystems already.

>  I don't want to end up with a situration like Posix ACLs again where
> different file systems using different on disk formats again.

Any file system could choose a different on-disk format than the one
that ext4 currently uses, but I don't see a reason why any should.
Apart from uid / gid mappings that is the same as the user-space xattr
format. Network file systems like NFSv4 and CIFS with their predefined
over-the-wire formats obviously are another story.

Thanks,
Andreas
