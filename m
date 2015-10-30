Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33472 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758952AbbJ3PCd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Oct 2015 11:02:33 -0400
Received: by lfbf136 with SMTP id f136so20339846lfb.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2015 08:02:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKCW0Y78D15MhRcxNtS2=0xQPowPFBPw43L=OLQE=1WJd8Acuw@mail.gmail.com>
References: <CAKCW0Y78D15MhRcxNtS2=0xQPowPFBPw43L=OLQE=1WJd8Acuw@mail.gmail.com>
From: Jeenu Viswambharan <jeenuv@gmail.com>
Date: Fri, 30 Oct 2015 15:02:02 +0000
Message-ID: <CAKCW0Y4U6jhqr=PVnSjVZP5T2Q_5qLXOpfHmsyCYUCRsMcKEuw@mail.gmail.com>
Subject: Re: NFS mount timeouts
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 30, 2015 at 2:54 PM, Jeenu Viswambharan <jeenuv@gmail.com> wrote:
> I've a development board whose root file system is shared via. NFS
> from my PC (3.13.0-66-generic #108-Ubuntu SMP x86_64 GNU/Linux). The
> behaviour at times is that board mounts the NFS share, but then soon
> thereafter, while in execution, it started displaying NFS timeouts,
> retries, and hangs. That's the end of it.

I missed to mention that once this happens, the board won't boot
again: it'll wait for the root file system to be mounted, fails, and
then crashes. Even restarting NFS server doesn't help.

-- 
Jeenu
