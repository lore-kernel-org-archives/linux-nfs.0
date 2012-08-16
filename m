Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59673 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670Ab2HPVQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2012 17:16:31 -0400
Received: by pbbrr13 with SMTP id rr13so2158596pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Aug 2012 14:16:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 16 Aug 2012 23:16:09 +0200
Message-ID: <CAJ75kXYufGtzcALR0VXW4+q3WxMAbQTbjwrQ-vOBv0CfGPinJA@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFS: Clear key construction data if the idmap upcall fails
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Shai Lazmi <shai.lazmi@qlogic.com>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thank you for the re-work patch.

On Thu, Aug 16, 2012 at 10:23 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> idmap_pipe_downcall already clears this field if the upcall succeeds,
> but if it fails (rpc.idmapd isn't running) the field will still be set
> on the next call triggering a BUG_ON().  This patch tries to handle all
> possible ways that the upcall could fail and clear the idmap key data
> for each one.
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> Cc: stable@vger.kernel.org [>= 3.4]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Tested-by: William Dauchy <wdauchy@gmail.com>

This patch works on my last tests. Sorry for the previous version
where I didn't saw the failure on my 64 bits tests.

Best regards,
-- 
William
