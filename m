Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tweak.unx.csupomona.edu ([134.71.247.20]:36656 "EHLO
	tweak.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758427Ab0J1XPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 19:15:38 -0400
Date: Thu, 28 Oct 2010 16:15:36 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpc.gssd still spammed in 2.6.35
Message-ID: <20101028161536.41358127@csupomona.edu>
In-Reply-To: <1288274419.3194.33.camel@heimdal.trondhjem.org>
References: <20101027172452.68b944ec@csupomona.edu>
	<1288274419.3194.33.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 28 Oct 2010 07:00:19 -0700
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> What about the rpc_pipefs errors, EAGAIN, EPIPE and ETIMEDOUT? Why
> should they result in the cred being marked as negative?
> 

I have a limited grasp of the exact mechanics going on, but the general
reasoning I have in my mind is this:

If a given credential request causes an error to be returned, be it
from rpc_pipefs or rpc.gssd, there are two possible reasons for the
failure:

1) rpc.gssd is missing or unresponsive.  If this is the case, it doesn't
matter if you can retry immediately or if you wait 5 seconds, it's
still going to fail.

2) Something about the request has caused either rpc_pipefs or rpc.gssd
to produce an error, while other requests still process normally. If
this is the case, we should prioritize the requests that will succeed
by penalizing the requests that don't via negative caching of their
failures. Otherwise those failing requests can flood rpc.gssd and
prevent those that can succeed from ever being attempted (and this is
what has been happening in my environment).


The only problem I can see with it is that, if a request fails and the
keys become available within 5 seconds, the user just has to wait it
out. I don't think I can usually "kinit" with my password in 5 seconds,
but I could see an automated system being interfered with.  I haven't
experimented with it, but I suspect a sub-second negative cache timeout
would still protect rpc.gssd from flooding while not causing extra
disruption to use.

I'd really just like to see some sort of rate-limiting on the failures
heading into rpc.gssd so that it can continue processing valid requests.

> rpc.gssd itself will only pass down 3 errors: 0, EKEYEXPIRED and EACCES.
> 

Is this set in stone?  My fear is that, if rpc.gssd is ever improved to
return even more error codes or can somehow be coerced to return some
other unexpected error code, rpc.gssd can be taken out of service by
flooding it with requests that subvert the negative caching.


Sorry if I'm out of touch with the internals or what's best for the
kernel.  I'm just a sysadmin dabbling in the kernel, trying to fix some
problems I've been running into...
