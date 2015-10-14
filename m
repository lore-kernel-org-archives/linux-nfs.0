Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:22844 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbbJNTjZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 15:39:25 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org> <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org>
 <CALCETrWrHs6x+aZ7c=sySRCdzwdfUQZH_DL++vLL78NXXN+7FQ@mail.gmail.com>
 <20151014184946.GA15214@infradead.org>
 <CALCETrV2ZG=EV5KLEeOERSbDjXCyaULAn0k34msSPFWvf0Tm9w@mail.gmail.com>
 <561EA997.9020402@gmail.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <561EAF69.9000905@draigBrady.com>
Date: Wed, 14 Oct 2015 20:39:21 +0100
MIME-Version: 1.0
In-Reply-To: <561EA997.9020402@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14/10/15 20:14, Austin S Hemmelgarn wrote:
> On 2015-10-14 14:53, Andy Lutomirski wrote:
>> On Wed, Oct 14, 2015 at 11:49 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>> On Wed, Oct 14, 2015 at 11:38:13AM -0700, Andy Lutomirski wrote:
>>>> One might argue that reflink is like copy + immediate dedupe.
>>>
>>> Not, it's not.  It's all that and more, because it is an operation that
>>> is atomic vs other writes to the file and it's an operation that either
>>> clones the whole range or nothing.  That's a very important difference.
>>
>> Fair enough.
>>
>> Would copy_file_range without the reflink option removed still be
>> permitted to link blocks on supported filesystems (btrfs and maybe
>> XFS)?
> I would argue that it should have such functionality, but not do so by 
> default (maybe add some option to tell it to ask the FS to accelerate 
> the copy operation?).

Heh, so back to the REFLINK flag :)
TBH given the overlap between "copy" and "reflink",
I quite like the REFLINK flag as a general interface to reflink.

thanks,
Pádraig
