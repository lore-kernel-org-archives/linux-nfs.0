Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33764 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759375Ab2HJKLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 06:11:14 -0400
Received: by pbbrr13 with SMTP id rr13so2482769pbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2012 03:11:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344535551-4412-3-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com> <1344535551-4412-3-git-send-email-bjschuma@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 10 Aug 2012 12:10:53 +0200
Message-ID: <CAJ75kXaYhQ8_Vw72j1Am5AxhHATsoEaOzh6JXA=buqeN38-8xA@mail.gmail.com>
Subject: Re: [PATCH 3/3] NFS: Use kzalloc() instead of kmalloc() in the idmapper
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 8:05 PM,  <bjschuma@netapp.com> wrote:
> This will allocate memory that has already been zeroed, allowing us to
> remove the memset later on.
>
> Signed-off-by: Bryan Schumaker <bjchuma@netapp.com>

Tested-by: William Dauchy <wdauchy@gmail.com>
Cc: stable@vger.kernel.org

-- 
William
