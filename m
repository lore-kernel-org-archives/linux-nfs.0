Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36379 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbbIHTLB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2015 15:11:01 -0400
Received: by oibi136 with SMTP id i136so65094733oib.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2015 12:11:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55EF279B.3020101@Netapp.com>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com> <55EF279B.3020101@Netapp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 8 Sep 2015 12:10:41 -0700
Message-ID: <CALCETrXxRB-LXVb+=nkwfj0zEjWuXXTctkSAc9Oec0fgyOQ5Yg@mail.gmail.com>
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>,
        linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 8, 2015 at 11:23 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 09/08/2015 11:21 AM, Pádraig Brady wrote:
>> I see copy_file_range() is a reflink() on BTRFS?
>> That's a bit surprising, as it avoids the copy completely.
>> cp(1) for example considered doing a BTRFS clone by default,
>> but didn't due to expectations that users actually wanted
>> the data duplicated on disk for resilience reasons,
>> and for performance reasons so that write latencies were
>> restricted to the copy operation, rather than being
>> introduced at usage time as the dest file is CoW'd.
>>
>> If reflink() is a possibility for copy_file_range()
>> then could it be done optionally with a flag?
>
> The idea is that filesystems get to choose how to handle copies in the default case.  BTRFS could do a reflink, but NFS could do a server side copy instead.  I can change the default behavior to only do a data copy (unless the reflink flag is specified) instead, if that is desirable.
>
> What does everybody think?

I think the best you could do is to have a hint asking politely for
the data to be deep-copied.  After all, some filesystems reserve the
right to transparently deduplicate.

Also, on a true COW filesystem (e.g. btrfs sometimes), there may be no
advantage to deep copying unless you actually want two copies for
locality reasons.

--Andy
