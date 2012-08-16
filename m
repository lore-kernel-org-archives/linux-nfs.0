Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39377 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab2HPPHl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2012 11:07:41 -0400
Received: by yhmm54 with SMTP id m54so2986734yhm.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2012 08:07:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXZSV=gCX1CYFocLHiHf_7D13ysk35cA-y0pyCiDzpnT3w@mail.gmail.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
 <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com> <CAJ75kXZSV=gCX1CYFocLHiHf_7D13ysk35cA-y0pyCiDzpnT3w@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 16 Aug 2012 17:07:20 +0200
Message-ID: <CAJ75kXbdvKiGt9bYvD1Wu-b6ZkVS0yG2YdkkuS7O+r_-+ynPWQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall fails
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 16, 2012 at 3:45 PM, William Dauchy <wdauchy@gmail.com> wrote:
> On another setup, this patch is breaking the legacy mapping.
> rpc.idmapd is running but it can't map any user. I'm trying to see the
> difference with the previous test I made.

my second test is on 64 bits (the previous was on 32 bits).
I'm also getting many errors from the userland:
rpc.idmapd: nfscb: write(/var/lib/nfs/rpc_pipefs/nfs/clnt4/idmap): No
space left on device

I assume this is because of adding `im_private` in `struct idmap_msg`
since removing the field resolves the issue.
I tried to find a wrong sizeof regarding `struct idmap_msg` but didn’t
found any thing at the moment.

-- 
William
