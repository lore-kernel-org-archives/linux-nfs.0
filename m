Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:48382 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2HJKJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 06:09:46 -0400
Received: by ghrr11 with SMTP id r11so1406018ghr.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2012 03:09:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 10 Aug 2012 12:09:24 +0200
Message-ID: <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall fails
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 8:05 PM,  <bjschuma@netapp.com> wrote:
> idmap_pipe_downcall already clears this field if the upcall succeeds,
> but if it fails (rpc.idmapd isn't running) the field will still be set
> on the next call triggering a BUG_ON().  This patch tries to handle all
> possible ways that the upcall could fail and clear the idmap key data
> for each one.

strange, I was also getting the BUG_ON even with an idmap running.

I tested this patch on top of a 3.4.8 kernel; before the patch, I was
unable to mount a nfsv4 mount correctly. I think this should also go
in stable.

> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

Tested-by: William Dauchy <wdauchy@gmail.com>
Cc: stable@vger.kernel.org
-- 
William
