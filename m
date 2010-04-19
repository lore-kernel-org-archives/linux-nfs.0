From: Michael O'Donnell <modonnell-kx56TfycDUc@public.gmane.org>
Subject: Re: NFS stops responding
Date: Mon, 19 Apr 2010 10:34:12 -0400
Message-ID: <4BCC69E4.70405@wsi.com>
References: <4BC62E38.3010704@wsi.com> <20100416201700.215b0bea.dennisn@dennisn.dyndns.org>
Reply-To: Michael O'Donnell <modonnell-kx56TfycDUc@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wsi-135-27.wsi.com ([8.8.135.27]:56876 "EHLO
	EXCHANGE.wsicorp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab0DSOeN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 10:34:13 -0400
In-Reply-To: <20100416201700.215b0bea.dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well, it's encouraging to finally get a response and even more so that
you may be seeing the same kinds of failures.  I will post logging output
from /var/log/messages from the client and server machines while the
failures are occurring and maybe we can compare notes?


Dennis Nezic wrote:
> Well I for one am convinced there is a bug either in the linux kernel,
> or somewhere. I have a similar problem (I posted about it here on March
> 18 2010), where NFS activity very frequently hangs for several minutes,
> for no good reason. (Changing the nfs mount option to "hard" should get
> rid of the I/O Errors, but it's still incredibly frustrating/annoying
> -- it will simply retry after precious minutes have been wasted, instead
> of failing :b). My problems began ONLY after I upgraded my server's
> kernel. When did yours begin?
> 
> I have noticed that when a client hangs, other clients still work --
> ie. the nfs server is still (sortof) working -- so I imagine there is
> something wrong with the client too?
>
