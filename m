Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34844 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbbJPMY6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 08:24:58 -0400
Date: Fri, 16 Oct 2015 05:24:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: P??draig Brady <P@draigBrady.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
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
Message-ID: <20151016122453.GB5889@infradead.org>
References: <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org>
 <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org>
 <5620E3A1.90408@gmail.com>
 <5620E74F.50006@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5620E74F.50006@draigBrady.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 01:02:23PM +0100, P??draig Brady wrote:
> Right. reflinking is transparent to the user, though its consequences are not.
> Consequences being the possible extra latency or ENOSPC on CoW.

You can get all these consequences without doing the file system reflink
by using a COW file system, any dedup scheme or thinly provisioned or
COW storage devices.

> Therefore reflinking should be an explicit action/flag IMHO.

This still does not make any sense, as it only prevents one of many
ways a file could do COW operations underneath.  If you don't want
ENOSPC use fallocate, or the proposed COPY_FALLOC flag.  If you want
care about latency you need to carefull benchmark your setup but in
general falloc / COPY_FALLOC might be a good starting point.  But for
99% of the copies a reflink is exactly the right thing to do.
