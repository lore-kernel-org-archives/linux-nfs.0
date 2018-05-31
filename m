Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56474 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754067AbeEaT2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 15:28:20 -0400
Date: Thu, 31 May 2018 15:28:20 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Shawn Lu (shawlu)" <shawlu@cisco.com>
Cc: Joshua Watt <jpewhacker@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is "unmount -f"  worked as expected?
Message-ID: <20180531192820.GB3557@fieldses.org>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
 <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
 <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
 <20180531151819.GC1298@fieldses.org>
 <C8362635-4E93-4C96-9827-E241565D27DF@cisco.com>
 <20180531173456.GE1298@fieldses.org>
 <D009E9C8-FB2B-4D93-BD91-EB4B47FCA983@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <D009E9C8-FB2B-4D93-BD91-EB4B47FCA983@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 06:04:52PM +0000, Shawn Lu (shawlu) wrote:
>  Yes, This will a big issue for cross mount.  Luckily, we have not
>  experience it yet due to low traffic.  
> 
>  By the way,  what is your suggestion on the road to enhance “umount
>  –f” ?   Will add kernel config option to support guaranteed force
>  unmount helps?

I honestly haven't been following that discussion.  If I were going to
work on this I'd start by studying the previous discussion that Joshua
references.

--b.
