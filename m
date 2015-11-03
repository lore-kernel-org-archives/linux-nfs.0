Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35711 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbKCJJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 04:09:43 -0500
Received: by lfbn126 with SMTP id n126so10106883lfb.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 01:09:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKCW0Y4RpYhMbL5D_oCfLYhh8qQSMzfX9QNqRkRnsVD06dFSzg@mail.gmail.com>
References: <CAKCW0Y78D15MhRcxNtS2=0xQPowPFBPw43L=OLQE=1WJd8Acuw@mail.gmail.com>
 <CAKCW0Y4U6jhqr=PVnSjVZP5T2Q_5qLXOpfHmsyCYUCRsMcKEuw@mail.gmail.com> <CAKCW0Y4RpYhMbL5D_oCfLYhh8qQSMzfX9QNqRkRnsVD06dFSzg@mail.gmail.com>
From: Jeenu Viswambharan <jeenuv@gmail.com>
Date: Tue, 3 Nov 2015 09:09:12 +0000
Message-ID: <CAKCW0Y5K+0Y-PJ94+S1PjY8e3ktFxZZUhBPbH+bwiZ0UHbAenA@mail.gmail.com>
Subject: Re: NFS mount timeouts
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 2, 2015 at 12:00 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
> On Fri, Oct 30, 2015 at 3:02 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
>> On Fri, Oct 30, 2015 at 2:54 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
>>> I've a development board whose root file system is shared via. NFS
>>> from my PC (3.13.0-66-generic #108-Ubuntu SMP x86_64 GNU/Linux). The
>>> behaviour at times is that board mounts the NFS share, but then soon
>>> thereafter, while in execution, it started displaying NFS timeouts,
>>> retries, and hangs. That's the end of it.
>>
>> I missed to mention that once this happens, the board won't boot
>> again: it'll wait for the root file system to be mounted, fails, and
>> then crashes. Even restarting NFS server doesn't help.
>
> I found signs that the NFS server is probably allowing access to the
> said share, but for some reason Linux on my development board wouldn't
> boot. I found the following traces in syslog, indicating retries from
> the Linux boot:
>
> [...]

For closure, looks like the cause of the problem was that I didn't
specify "tcp" mount option in my nfsroot parameter. Also, if I don't
additionally mention "v3", file system accesses seem to be
particularly slow. With these options specified, file system is
getting mounted fine.

Oddly enough, this requirement turned mandatory out of the blue. I
never used to use these before!

-- 
Jeenu
