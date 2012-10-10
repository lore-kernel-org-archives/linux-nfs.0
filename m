Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36530 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab2JJKdJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Oct 2012 06:33:09 -0400
Message-ID: <50754EBC.5020608@parallels.com>
Date: Wed, 10 Oct 2012 14:32:28 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before connecting
 local transports
References: <20121008105437.18668.99905.stgit@localhost.localdomain> <20121009193506.GA19680@fieldses.org> <4FA345DA4F4AE44899BD2B03EEEC2FA90901A143@SACEXCMBX04-PRD.hq.netapp.com> <87txu3bdnj.fsf@xmission.com> <20121009223139.GA25826@fieldses.org> <87bogb1cvl.fsf@xmission.com> <20121010012336.GA2935@fieldses.org>
In-Reply-To: <20121010012336.GA2935@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.10.2012 05:23, J. Bruce Fields пишет:
> On Tue, Oct 09, 2012 at 03:47:42PM -0700, Eric W. Biederman wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>
>>> On Tue, Oct 09, 2012 at 01:20:48PM -0700, Eric W. Biederman wrote:
>>>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:
>>>>
>>>>> On Tue, 2012-10-09 at 15:35 -0400, J. Bruce Fields wrote:
>>>>>> Cc'ing Eric since I seem to recall he suggested doing it this way?
>>>>
>>>> Yes.  On second look setting fs->root won't work. We need to change fs.
>>>> The problem is that by default all kernel threads share fs so changing
>>>> fs->root will have non-local consequences.
>>>
>>> Oh, huh.  And we can't "unshare" it somehow?
>>
>> I don't fully understand how nfs uses kernel threads and work queues.
>> My general understanding is work queues reuse their kernel threads
>> between different users.  So it is mostly a don't pollute your
>> environment thing.  If there was a dedicated kernel thread for each
>> environment this would be trivial.
>>
>> What I was suggesting here is changing task->fs instead of
>> task->fs.root.  That should just require task_lock().
>
> Oh, OK, got it--if that works, great.
>

The main problem with swapping fs struct is actually the same as in root 
swapping. I.e. routines for copy fs_struct are not exported.
It could be done on place, but I don't think, that Al Viro would support such 
implementation.
Trond?

>>> Sorry, I don't know much about devtmpfs, are you suggesting it as a
>>> model?  What exactly should we look at?
>>
>> Roughly all I meant was that devtmpsfsd is a kernel thread that runs
>> with an unshared fs struct.  Although I admit devtmpfsd is for all
>> practical purposes a userspace daemon that just happens to run in kernel
>> space.
>
> Thanks for the explanation.
>
> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
