Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64152 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2HJKKg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 06:10:36 -0400
Received: by pbbrr13 with SMTP id rr13so2481954pbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2012 03:10:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344535551-4412-2-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com> <1344535551-4412-2-git-send-email-bjschuma@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 10 Aug 2012 12:10:15 +0200
Message-ID: <CAJ75kXZizTP-6KuQj85UeHV1-jYCXGnWMTQO7jDsOtJdfh9bDg@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFS: return -ENOKEY when the upcall fails to map the name
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 8:05 PM,  <bjschuma@netapp.com> wrote:
> This allows the normal error-paths to handle the error, rather than
> making a special call to complete_request_key() just for this instance.
>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

Tested-by: William Dauchy <wdauchy@gmail.com>
Cc: stable@vger.kernel.org

-- 
William
