From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/8] rpcbind v4 support in net/sunrpc/svc*
Date: Mon, 21 Jul 2008 15:07:48 -0400
Message-ID: <76bd70e30807211207q4fc509e0h4a1a560fe8097de7@mail.gmail.com>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
	 <20080719010738.GA19106@fieldses.org>
	 <20080720211744.GA32178@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:42838 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbYGUTHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 15:07:50 -0400
Received: by mu-out-0910.google.com with SMTP id w8so927541mue.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2008 12:07:48 -0700 (PDT)
In-Reply-To: <20080720211744.GA32178@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 20, 2008 at 5:17 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Jul 18, 2008 at 09:07:38PM -0400, J. Bruce Fields wrote:
>> On Mon, Jun 30, 2008 at 06:45:21PM -0400, Chuck Lever wrote:
>> > Hi Bruce, Trond -
>> >
>> > These implement basic support in net/sunrpc/svc* for registering IPv6-
>> > enabled kernel RPC services with the local user-space rpcbind.  These
>> > all depend on the new rpcb_v4_register() API I just posted.
>> >
>> > The last patch enables IPv6 support for the NFSv4 callback service, even
>> > though it doesn't register with rpcbind.
>>
>> There's some conflicts against my latest tree.  Would it be possible to
>> rebase to
>>
>>       git://linux-nfs.org/~bfields/linux.git for-2.6.27
>>
>> sometime?
>
> Actually, never mind, I fixed up the conflicts in the first couple and
> staged them here:
>
>        git://linux-nfs.org/~bfields/linux.git for-2.6.28
>
> (I think the rest'll still apply cleanly to that.)
>
> We could maybe still try to get the rest of this in at the end of the
> 2.6.27 merge window, but I'm inclined to wait.  Apologies, partly my
> fault for not getting around to these sooner.

Given the complexity and controversy of these changes, the number of
other changes that went into .27 and will require us to rewrite some
of these, and the pending holiday/travel for our team of maintainers,
I think waiting for .28 is our only choice.

-- 
 "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
--Dr. Evil
