Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40832 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752475Ab0K3WLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 17:11:06 -0500
In-Reply-To: <1291138954-10310-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1291138954-10310-1-git-send-email-Trond.Myklebust@netapp.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Nov 2010 14:10:44 -0800
Message-ID: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix a readdirplus bug
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 9:42 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> When comparing filehandles in the helper nfs_same_file(), we should not be
> using 'strncmp()': filehandles are not null terminated strings.

Hmm. Applied, but sadly Nick Bowler <nbowler@elliptictech.com> reports
that it doesn't actually fix his problem, so there is still a serious
regression there.

                Linus
