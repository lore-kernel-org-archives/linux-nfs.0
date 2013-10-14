Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f175.google.com ([209.85.128.175]:58820 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab3JNPwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 11:52:07 -0400
Received: by mail-ve0-f175.google.com with SMTP id pa12so9084veb.20
        for <linux-nfs@vger.kernel.org>; Mon, 14 Oct 2013 08:52:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55848506-CAF1-47C5-9442-0E3AB3D2A398@netapp.com>
References: <1381188833-3728-1-git-send-email-dros@netapp.com> <55848506-CAF1-47C5-9442-0E3AB3D2A398@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 14 Oct 2013 17:51:44 +0200
Message-ID: <CAJ75kXZT5HPqh8oMw8LTzNMxVYQm8o01+m8_ghufaTfiD60Pew@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Fix NULL dereference in recovery path
To: Weston Andros Adamson <dros@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 8, 2013 at 1:40 AM, Weston Andros Adamson <dros@netapp.com> wrote:
> This is the bug I found at the bakeathon. I can finally reproduce it quickly! And in a shockingly easy way!
> Tomorrow I'll figure out how long this regression has been present and if we need to CC stable.

Any news on that? Does it apply on older version?

Thanks,

-- 
William
