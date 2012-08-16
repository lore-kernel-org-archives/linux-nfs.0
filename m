Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43368 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab2HPNqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2012 09:46:07 -0400
Received: by pbbrr13 with SMTP id rr13so1612668pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2012 06:46:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com> <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 16 Aug 2012 15:45:46 +0200
Message-ID: <CAJ75kXZSV=gCX1CYFocLHiHf_7D13ysk35cA-y0pyCiDzpnT3w@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall fails
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bryan,

On Fri, Aug 10, 2012 at 12:09 PM, William Dauchy <wdauchy@gmail.com> wrote:
> strange, I was also getting the BUG_ON even with an idmap running.

On another setup, this patch is breaking the legacy mapping.
rpc.idmapd is running but it can't map any user. I'm trying to see the
difference with the previous test I made.

-- 
William
