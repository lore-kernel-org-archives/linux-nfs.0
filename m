Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60703 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbJPMWB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 08:22:01 -0400
Date: Fri, 16 Oct 2015 05:21:51 -0700
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
Message-ID: <20151016122151.GA5889@infradead.org>
References: <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org>
 <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org>
 <5620E3A1.90408@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5620E3A1.90408@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 07:46:41AM -0400, Austin S Hemmelgarn wrote:
> I should have been specific, what I meant was that some people will assume
> that it actually creates a physical, on-disk byte-for-byte copy of the data.
> There are many people out there (and sadly I have to deal with some at work)
> who are absolutely terrified of the concept of data deduplication, and will
> likely refuse to use this syscall for _anything_ if it reflinks by default
> on filesystems that support it.

If they use a file system that supports COW or dedup they are toast
already.  It's not the system call that does the 'dedup', it's the file
system or storage device, that's where they need to set their
preferences.
