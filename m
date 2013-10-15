Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:36595 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932510Ab3JORnR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 13:43:17 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Fix NULL dereference in recovery path
Date: Tue, 15 Oct 2013 17:43:16 +0000
Message-ID: <300B01EF-CEB0-41EE-BAF4-655728DF90EE@netapp.com>
References: <1381188833-3728-1-git-send-email-dros@netapp.com>
 <55848506-CAF1-47C5-9442-0E3AB3D2A398@netapp.com>
 <CAJ75kXZT5HPqh8oMw8LTzNMxVYQm8o01+m8_ghufaTfiD60Pew@mail.gmail.com>
In-Reply-To: <CAJ75kXZT5HPqh8oMw8LTzNMxVYQm8o01+m8_ghufaTfiD60Pew@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I plan on bisecting this next time I get a few spare cycles.

-dros

On Oct 14, 2013, at 11:51 AM, William Dauchy <wdauchy@gmail.com> wrote:

> On Tue, Oct 8, 2013 at 1:40 AM, Weston Andros Adamson <dros@netapp.com> wrote:
>> This is the bug I found at the bakeathon. I can finally reproduce it quickly! And in a shockingly easy way!
>> Tomorrow I'll figure out how long this regression has been present and if we need to CC stable.
> 
> Any news on that? Does it apply on older version?
> 
> Thanks,
> 
> -- 
> William

