Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33189 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbbJNSyI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 14:54:08 -0400
Received: by obbwb3 with SMTP id wb3so20404364obb.0
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 11:54:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014184946.GA15214@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org> <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com> <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org> <CALCETrWrHs6x+aZ7c=sySRCdzwdfUQZH_DL++vLL78NXXN+7FQ@mail.gmail.com>
 <20151014184946.GA15214@infradead.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 Oct 2015 11:53:45 -0700
Message-ID: <CALCETrV2ZG=EV5KLEeOERSbDjXCyaULAn0k34msSPFWvf0Tm9w@mail.gmail.com>
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:49 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Oct 14, 2015 at 11:38:13AM -0700, Andy Lutomirski wrote:
>> One might argue that reflink is like copy + immediate dedupe.
>
> Not, it's not.  It's all that and more, because it is an operation that
> is atomic vs other writes to the file and it's an operation that either
> clones the whole range or nothing.  That's a very important difference.

Fair enough.

Would copy_file_range without the reflink option removed still be
permitted to link blocks on supported filesystems (btrfs and maybe
XFS)?

--Andy
