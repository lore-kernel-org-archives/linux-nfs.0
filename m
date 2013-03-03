Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:50505 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab3CCAi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Mar 2013 19:38:58 -0500
Received: by mail-qe0-f53.google.com with SMTP id cz11so3183483qeb.12
        for <linux-nfs@vger.kernel.org>; Sat, 02 Mar 2013 16:38:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130303002054.GA20389@fieldses.org>
References: <20130302212411.GB3678@htj.dyndns.org>
	<20130303002054.GA20389@fieldses.org>
Date: Sat, 2 Mar 2013 16:38:57 -0800
Message-ID: <CAOS58YOQhEcpWfFmT99NEoUJeDJqbK8xve=9HUufYjseNCu=KA@mail.gmail.com>
Subject: Re: status of idr_alloc() conversion in nfsd?
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 2, 2013 at 4:20 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Whoops, sorry, I think I assumed you'd do it.
>
> The prerequisite cleanup is upstream now, so I think it should be
> straightforward?
>
> Let me know if you want me to do it, or I'm happy to ACK anything of
> yours.

Ooh, right, I forgot to check whether the logic around it has changed.
Sorry about that. I'll do the conversion. There are several other
conversions that I need to do anyway.

Thanks a lot!

-- 
tejun
