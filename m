Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33936 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbbKBMBZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 07:01:25 -0500
Received: by lfgh9 with SMTP id h9so13894030lfg.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 04:01:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKCW0Y4U6jhqr=PVnSjVZP5T2Q_5qLXOpfHmsyCYUCRsMcKEuw@mail.gmail.com>
References: <CAKCW0Y78D15MhRcxNtS2=0xQPowPFBPw43L=OLQE=1WJd8Acuw@mail.gmail.com>
 <CAKCW0Y4U6jhqr=PVnSjVZP5T2Q_5qLXOpfHmsyCYUCRsMcKEuw@mail.gmail.com>
From: Jeenu Viswambharan <jeenuv@gmail.com>
Date: Mon, 2 Nov 2015 12:00:53 +0000
Message-ID: <CAKCW0Y4RpYhMbL5D_oCfLYhh8qQSMzfX9QNqRkRnsVD06dFSzg@mail.gmail.com>
Subject: Re: NFS mount timeouts
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 30, 2015 at 3:02 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
> On Fri, Oct 30, 2015 at 2:54 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
>> I've a development board whose root file system is shared via. NFS
>> from my PC (3.13.0-66-generic #108-Ubuntu SMP x86_64 GNU/Linux). The
>> behaviour at times is that board mounts the NFS share, but then soon
>> thereafter, while in execution, it started displaying NFS timeouts,
>> retries, and hangs. That's the end of it.
>
> I missed to mention that once this happens, the board won't boot
> again: it'll wait for the root file system to be mounted, fails, and
> then crashes. Even restarting NFS server doesn't help.

I found signs that the NFS server is probably allowing access to the
said share, but for some reason Linux on my development board wouldn't
boot. I found the following traces in syslog, indicating retries from
the Linux boot:

  Nov  2 11:48:26 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:912 for /work/nfs (/work/nfs)
  Nov  2 11:49:09 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:899 for /work/nfs (/work/nfs)
  Nov  2 11:50:02 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:871 for /work/nfs (/work/nfs)
  Nov  2 11:51:15 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:759 for /work/nfs (/work/nfs)
  Nov  2 11:52:48 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:999 for /work/nfs (/work/nfs)
  Nov  2 11:54:21 e105349-lin rpc.mountd[7920]: authenticated mount
request from 10.1.197.27:792 for /work/nfs (/work/nfs)

Also, there are entries in /var/lib/nfs/rmtab for the said NFS share.
For some reason the board isn't happy with all these, and gives up
citing NFS timeout:

  [  197.211808] VFS: Unable to mount root fs via NFS, trying floppy.
  [  197.214885] VFS: Cannot open root device "nfs" or
unknown-block(2,0): error -6
  [  197.218459] Please append a correct "root=" boot option; here are
the available partitions:
  [  197.222611] Kernel panic - not syncing: VFS: Unable to mount root
fs on unknown-block(2,0)
  [  197.226702] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc8+ #2

Could somebody help diagnose the problem please?

-- 
Jeenu
