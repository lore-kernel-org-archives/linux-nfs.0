Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603Ab0K3WNc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 17:13:32 -0500
Subject: Re: [PATCH] NFS: Fix a readdirplus bug
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
References: <1291138954-10310-1-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 17:13:24 -0500
Message-ID: <1291155204.2998.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 14:10 -0800, Linus Torvalds wrote:
> On Tue, Nov 30, 2010 at 9:42 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > When comparing filehandles in the helper nfs_same_file(), we should not be
> > using 'strncmp()': filehandles are not null terminated strings.
> 
> Hmm. Applied, but sadly Nick Bowler <nbowler@elliptictech.com> reports
> that it doesn't actually fix his problem, so there is still a serious
> regression there.
> 
>                 Linus

OK. I'll follow up that problem with him.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

