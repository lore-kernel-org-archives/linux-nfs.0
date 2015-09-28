Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:5174 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757516AbbI1O2Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 10:28:24 -0400
Subject: Re: [PATCH v3 8/9] vfs: copy_file_range() can do a pagecache copy
 with splice
To: Andy Lutomirski <luto@amacapital.net>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443214096-12769-9-git-send-email-Anna.Schumaker@Netapp.com>
 <CALCETrWLAwNVqAiTMOmaktVY0cQkM0bX2vztXzEHm3EFYDg6zA@mail.gmail.com>
CC: <linux-nfs@vger.kernel.org>,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, <andros@netapp.com>,
        Christoph Hellwig <hch@infradead.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <56094E82.2070800@Netapp.com>
Date: Mon, 28 Sep 2015 10:28:18 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrWLAwNVqAiTMOmaktVY0cQkM0bX2vztXzEHm3EFYDg6zA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/25/2015 08:14 PM, Andy Lutomirski wrote:
> On Fri, Sep 25, 2015 at 1:48 PM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
>> The NFS server will need some kind offallback for filesystems that don't
>> have any kind of copy acceleration, and it should be generally useful to
>> have an in-kernel copy to avoid lots of switches between kernel and user
>> space.
>>
>> I make this configurable by adding two new flags.  Users who only want a
>> reflink can pass COPY_FR_REFLINK, and users who want a full data copy can
>> pass COPY_FR_COPY.  The default (flags=0) means to first attempt a
>> reflink, but use the pagecache if that fails.
>>
> 
> Can you clarify how the subject line fits in?  I'm a bit lost.

I'll try!  I use the splice interface to copy file data from the pagecache, and this implements an in-kernel copy that can be controlled using the two flags I added.

I plan on using this in the NFS server when I add server-side copy support.

Let me know if that doesn't answer your question!
Anna

> 
> --Andy
> 

