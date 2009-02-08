From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sun, 8 Feb 2009 00:25:43 -0500
Message-ID: <20090208052543.GA20689@fieldses.org>
References: <20090206.140714.201930500.davem@davemloft.net> <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com> <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi> <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	chuck.lever@oracle.com, trond@netapp.com,
	linux-nfs@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46618 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbZBHFZq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2009 00:25:46 -0500
In-Reply-To: <Pine.LNX.4.64.0902071831210.2805-x/A8LOkYjdVsRR2hCrRKtT03IgOmwywn@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 07, 2009 at 06:56:03PM +0200, Ilpo J=C3=A4rvinen wrote:
> I personally think that people were honestly just mislead to think th=
at
> diff-funcs output is part of the patch

Yes, exactly, in my case, that's all it was--the "diff" I thought I saw
in my 2-second skim looked odd, and I figured a comment might have
gotten dropped off in the process of replying and adding cc's--hence th=
e
original question.

Anyway, the patch looks obviously fine to me, and the diff-func and
codiff output are helpful.  (Where's diff-func from?)

In similar cases in the future, if you want to cater to the more tired
and/or mentally challenged among us (which may just be me), some clue
that visually distinguishes the quoted diff output in the comment might
help; e.g., maybe indent it like the below.

(But that's intended as a suggestion, not a requirement.)

--b.

Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found

diff-func output suggests these functions are very similar:

	$ diff-funcs xs_udp_write_space net/sunrpc/xprtsock.c
	 ...(etc)

and codiff shows the space savings:

	$ codiff net/sunrpc/xprtsock.o net/sunrpc/xprtsock.o.new
	...(etc)

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
