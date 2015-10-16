Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52519 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbJPFiV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 01:38:21 -0400
Date: Thu, 15 Oct 2015 22:38:08 -0700
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
Message-ID: <20151016053808.GA29510@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org>
 <561F9B13.7020804@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <561F9B13.7020804@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 15, 2015 at 08:24:51AM -0400, Austin S Hemmelgarn wrote:
> My only point with saying we shouldn't reflink by default is that there are
> many (unintelligent) people who will assume that since the syscall has copy
> in it's name, that's what it will do; and, while I don't think we should
> cater to such individuals, it does make sense to have a syscall that says in
> it's name that it copies data actually do so by default.

As far as the user is concerned a reflink is a copy.  A very efficient
copy.
