Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34767 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbbJPNMz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 09:12:55 -0400
Date: Fri, 16 Oct 2015 06:12:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151016131250.GA15345@infradead.org>
References: <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org>
 <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org>
 <5620E3A1.90408@gmail.com>
 <20151016122151.GA5889@infradead.org>
 <5620F2A1.4060504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5620F2A1.4060504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 08:50:41AM -0400, Austin S Hemmelgarn wrote:
> Certain parts of userspace do try to reflink things instead of copying (for
> example, coreutils recently started doing so in mv and has had the option to
> do so with cp for a while now), but a properly designed general purpose
> filesystem does not and should not do this without the user telling it to do
> so.

But they do.  Get out of your narrow local Linux file system view.
Every all flash array or hyperconverge hypervisor will dedeup the hell
out of your data, heck some SSDs even do it on the device.  Your NFS or
CIFS server already does or soon will do dedup and reflinks behind the
scenes, that's the whole point of adding these features to the protocol.

And except for the odd fear or COW or dedup, and the ENOSPC issue for
which we have a flag with a very well defined meaning I've still not
heard any good arguments against it.
