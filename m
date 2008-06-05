From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: [PATCH] nfs-utils:  "nfsstat -m" should report nfsv4 mounts  too.
Date: Thu, 5 Jun 2008 08:22:56 -0400
Message-ID: <DA6873AA-1B8F-4FCD-B45C-E66F3B8B4DC2@myri.com>
References: <18503.29174.373900.73302@notabene.brown> <18503.29397.511629.809568@notabene.brown> <4CC1DC65-88C3-4F26-8FF2-016F6C1173CE@myri.com> <35792.192.168.1.70.1212667686.squirrel@neil.brown.name>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "NeilBrown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1976 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753728AbYFEMXC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 08:23:02 -0400
In-Reply-To: <35792.192.168.1.70.1212667686.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 5, 2008, at 8:08 AM, NeilBrown wrote:

> Thanks for reviewing the patch (always appreciated), but no - I don't
> want OR.
> What I really want is to eradicate all usages of
>    if (strcmp(X,Y))
> in the world and make them
>    if (strcmp(X,Y) != 0)
>
> Then it is clearer that it is a "!=" test.
> In this case, the condition as I had it means"
>
>   If type is not nfs and type is not nfs4
> (then continue)
> which is what I want.
>
> Your version says:
>   If type is not nfs or type is not nfs4
>
> and that will always be true.
>
> +             if (strcmp(type, "nfs") != 0 && strcmp(type, "nfs4") ! 
> = 0)) {
>
>
> NeilBrown

Ahh, I did not provide much of a review since I missed your intent. :-)

Scott
