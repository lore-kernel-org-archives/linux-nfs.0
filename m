Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:35747 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbAWUJt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 15:09:49 -0500
MIME-Version: 1.0
In-Reply-To: <54C1DDA8.5040103@sandeen.net>
References: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com>
 <54C1DDA8.5040103@sandeen.net>
From: Steve French <smfrench@gmail.com>
Date: Fri, 23 Jan 2015 14:09:27 -0600
Message-ID: <CAH2r5mtL52=MYu225w5G-D8X9kAb1w0Zi-GhvOfyBzm-WVT0pQ@mail.gmail.com>
Subject: Re: xfstest generic/299
To: Eric Sandeen <sandeen@sandeen.net>
Cc: fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 11:35 PM, Eric Sandeen <sandeen@sandeen.net> wrote:
> On 1/22/15 11:23 PM, Steve French wrote:
>> Noticed test generic/299 failing over NFS (v4.1 dialect) with the error
>>
>> "[not run] /usr/bin/fio too old"
>>
>> fio-2.1.11 version (which is what is installed on current Ubuntu) is
>> presumably not too old
>
> Well, 2.1.11 was released 16-Jul-2014
>
> fio is up to 2.2.5 now, so it sure could be.

I updated to 2.2.5-3 (cloning and building from the repository on
git.kernel.org) which did not seem to change the results.

> The test sets up a config file, and tries to run fio against it;
> if it fails, it's deemed "too old"
>
> And _require_fio dumps to $seqres.full,
>
>         $FIO_PROG --warnings-fatal --showcmd $job >> $seqres.full 2>&1
>         [ $? -eq 0 ] || _notrun "$FIO_PROG too old, see $seqres.full"
>
> so what does 299.full look like?

min value out of range: 0 (1 min)
fio: failed parsing filesize=0
fio: job global dropped
fio --ioengine=libaio --bs=128k --directory=/mnt1/scratch --size=999G
--iodepth=128*1 --continue_on_error=write --ignore_error=,ENOSPC
--error_dump=0 --create_on_open=1 --fallocate=none --exitall=1



-- 
Thanks,

Steve
