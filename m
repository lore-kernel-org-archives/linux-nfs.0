Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41570 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757399Ab2HPPeq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2012 11:34:46 -0400
Received: by ggdk6 with SMTP id k6so3030233ggd.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2012 08:34:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502D0FF3.8010302@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
 <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com>
 <CAJ75kXZSV=gCX1CYFocLHiHf_7D13ysk35cA-y0pyCiDzpnT3w@mail.gmail.com>
 <CAJ75kXbdvKiGt9bYvD1Wu-b6ZkVS0yG2YdkkuS7O+r_-+ynPWQ@mail.gmail.com> <502D0FF3.8010302@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 16 Aug 2012 17:34:25 +0200
Message-ID: <CAJ75kXa8ekBm2SPDTsATxYccT0Wd9RUzfTDm5dAZD18er0eRLw@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall fails
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 16, 2012 at 5:21 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> I was afraid im_private would cause problems, but I wouldn't expect "No space left on device".  You did double check the output of `df`, right? :).

:)
yes.

> I'll play around with it soon to see what I can find.  Thanks for finding this!

Thanks. I'm also testing some stuff to find a possible solution.

-- 
William
