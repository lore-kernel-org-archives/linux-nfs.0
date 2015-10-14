Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36546 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbbJNSie convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 14:38:34 -0400
Received: by oihr205 with SMTP id r205so33046518oih.3
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2015 11:38:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014182701.GC31225@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org> <20151012231749.GC11398@birch.djwong.org>
 <561E980C.9010509@Netapp.com> <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 Oct 2015 11:38:13 -0700
Message-ID: <CALCETrWrHs6x+aZ7c=sySRCdzwdfUQZH_DL++vLL78NXXN+7FQ@mail.gmail.com>
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

On Wed, Oct 14, 2015 at 11:27 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Oct 14, 2015 at 11:08:40AM -0700, Andy Lutomirski wrote:
>> > So what I'm hearing is that I should drop the reflink and dedup flags and change this system call only perform a full copy (with preserving of sparseness), correct?  I can make those changes, but only if everybody is in agreement that it's the best way forward.
>>
>> I personally rather like the reflink option.  That thing is quite useful.
>
> reflink is very useful, probably more useful than the copy actually. But it
> is different from a copy.  It should be a separate interface.

One might argue that reflink is like copy + immediate dedupe.  Also, I
can imagine there being network protocols over which you can't really
tell the difference between reflink and server-to-server copy.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
