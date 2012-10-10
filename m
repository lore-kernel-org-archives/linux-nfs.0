Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53172 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab2JJSr5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Oct 2012 14:47:57 -0400
Message-ID: <5075C2D1.407@panasas.com>
Date: Wed, 10 Oct 2012 11:47:45 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH-Resend] NFS41: layoutget optimize and pnfsblock cleanup
References: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com> <507470AB.8030900@panasas.com> <507474F5.8050307@panasas.com> <CA+a=Yy4jw744eDR56o9JdVwzRBOakXZJpoY2mfkMrQ+LLkT0MA@mail.gmail.com>
In-Reply-To: <CA+a=Yy4jw744eDR56o9JdVwzRBOakXZJpoY2mfkMrQ+LLkT0MA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/10/2012 03:13 AM, Peng Tao wrote:
> Sorry I forgot to mention... They apply to Trond's nfs-for-next
> branch, commit (5f65753033d8c5a53e65810bff3832e8282c68d1).
> 

NP thanks, I just saw Trond's pull request patches are part of that
pull, I will test with 3.7-rc1 and will report if I have any problems.

Thanks Tao
Boaz

> Thanks,
> Tao
> 
