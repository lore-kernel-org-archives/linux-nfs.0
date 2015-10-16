Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:26371 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbbJPMC1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 08:02:27 -0400
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for
 pagecache copies
To: Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142203.GA31867@infradead.org>
 <20151012231749.GC11398@birch.djwong.org> <561E980C.9010509@Netapp.com>
 <CALCETrU0-Q-q0u0BAPwu+mbyS+LVp6M1Hqro3xwzSm7eNCbEmg@mail.gmail.com>
 <20151014182701.GC31225@infradead.org> <561EA83E.8080000@gmail.com>
 <20151015063621.GA3025@infradead.org> <561F9B13.7020804@gmail.com>
 <20151016053808.GA29510@infradead.org> <5620E3A1.90408@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <5620E74F.50006@draigBrady.com>
Date: Fri, 16 Oct 2015 13:02:23 +0100
MIME-Version: 1.0
In-Reply-To: <5620E3A1.90408@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16/10/15 12:46, Austin S Hemmelgarn wrote:
> On 2015-10-16 01:38, Christoph Hellwig wrote:
>> On Thu, Oct 15, 2015 at 08:24:51AM -0400, Austin S Hemmelgarn wrote:
>>> My only point with saying we shouldn't reflink by default is that there are
>>> many (unintelligent) people who will assume that since the syscall has copy
>>> in it's name, that's what it will do; and, while I don't think we should
>>> cater to such individuals, it does make sense to have a syscall that says in
>>> it's name that it copies data actually do so by default.
>>
>> As far as the user is concerned a reflink is a copy.  A very efficient
>> copy.
> I should have been specific, what I meant was that some people will 
> assume that it actually creates a physical, on-disk byte-for-byte copy 
> of the data.  There are many people out there (and sadly I have to deal 
> with some at work) who are absolutely terrified of the concept of data 
> deduplication, and will likely refuse to use this syscall for _anything_ 
> if it reflinks by default on filesystems that support it.

Right. reflinking is transparent to the user, though its consequences are not.
Consequences being the possible extra latency or ENOSPC on CoW.
Therefore reflinking should be an explicit action/flag IMHO.

cheers,
Pádraig.
