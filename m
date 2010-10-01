Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38986 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab0JACOM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 22:14:12 -0400
Received: by bwz11 with SMTP id 11so1897765bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 19:14:10 -0700 (PDT)
In-Reply-To: <20100930215220.GB7244@merit.edu>
References: <20100930171325.GA5731@merit.edu>
	<4CA503C2.2090607@panasas.com>
	<20100930215220.GB7244@merit.edu>
Date: Thu, 30 Sep 2010 22:14:10 -0400
Message-ID: <AANLkTi=bRwN3uoszG0jTzVSPMSwP6VKn+rW470uWwAj1@mail.gmail.com>
Subject: Re: another block layout oops
From: Fred Isaman <iisaman@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 5:52 PM, Jim Rees <rees@umich.edu> wrote:
> Benny Halevy wrote:
>
>  Jim, would you mind retesting with pnfs-all-2.6.36-rc6-2010-09-30?
>  Not that there's any possible fix there, but a fresh Oops could
>  help, if you can reproduce it.
>
> Will do, probably after an important meeting I have at 6:00 this evening.

There is a problem with the LAYOUTGET error handling, which is
probably what Jim is hitting  (the block servers are much more likely
to send RETRYLATER).  I'll send in a fix tomorrow morning.

Fred

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
