Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56466 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758139AbcLQS1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Dec 2016 13:27:47 -0500
Subject: Re: [PATCH] nfs-utils: start-statd script using incompatible file
 descriptor
To: Daniel Pocock <daniel@pocock.pro>, linux-nfs@vger.kernel.org
References: <70eeb75e-e48f-fb0a-a690-1c6c8cb0ede4@pocock.pro>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <fac98360-0651-a51b-e253-23fffa5cb36d@RedHat.com>
Date: Sat, 17 Dec 2016 13:27:45 -0500
MIME-Version: 1.0
In-Reply-To: <70eeb75e-e48f-fb0a-a690-1c6c8cb0ede4@pocock.pro>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, 

Could up please resubmit this patch with the
proper patch description (basically what 
problem you are fixing) and a proper 
 Signed-off-by: line.

steved.

On 12/17/2016 06:00 AM, Daniel Pocock wrote:
> 
> 
> The current script uses fd 200, doesn't work for every possible shell as
> reported[1] in Debian bug #848277
> 
> We are including a patch for it in the 1.3.4-2 package, it would be good
> to incorporate this patch upstream too.
> 
> Regards,
> 
> Daniel
> 
> 
> 1. https://bugs.debian.org/848277
> 
