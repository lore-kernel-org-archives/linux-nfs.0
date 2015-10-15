Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42360 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbbJOF4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 01:56:34 -0400
Date: Wed, 14 Oct 2015 22:56:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151015055630.GA8373@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <CALCETrWrHs6x+aZ7c=sySRCdzwdfUQZH_DL++vLL78NXXN+7FQ@mail.gmail.com>
 <20151014184946.GA15214@infradead.org>
 <CALCETrV2ZG=EV5KLEeOERSbDjXCyaULAn0k34msSPFWvf0Tm9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALCETrV2ZG=EV5KLEeOERSbDjXCyaULAn0k34msSPFWvf0Tm9w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:53:45AM -0700, Andy Lutomirski wrote:
> Would copy_file_range without the reflink option removed still be
> permitted to link blocks on supported filesystems (btrfs and maybe
> XFS)?

Absolutely.  Unless the COPY_FALLOCATE or whatever we call it option is
specified of course.  But I'd really love to get basic copy
infrastructure in for 4.4 and then define these options later.
