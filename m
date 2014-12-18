Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static.68.134.40.188.clients.your-server.de ([188.40.134.68]:51559
	"EHLO mail02.iobjects.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaLRTol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 14:44:41 -0500
Message-ID: <54932EA5.9090803@googlemail.com>
Date: Thu, 18 Dec 2014 20:44:37 +0100
From: =?UTF-8?B?SG9sZ2VyIEhvZmZzdMOkdHRl?=
	<holger.hoffstaette@googlemail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
References: <pan.2014.12.16.22.19.18@googlemail.com> <20141217212159.GA11517@fieldses.org> <5492C710.20104@googlemail.com> <20141218144856.GA18179@fieldses.org> <alpine.OSX.2.19.9992.1412180955000.62182@planck.local> <20141218151914.GB18179@fieldses.org> <pan.2014.12.18.15.42.53@googlemail.com> <20141218163254.GF18179@fieldses.org> <549303FC.9090604@googlemail.com> <20141218170653.GG18179@fieldses.org>
In-Reply-To: <20141218170653.GG18179@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/18/14 18:06, J. Bruce Fields wrote:
> Whoops, now I see, the server-side trace has the same problem, I
> just overlooked it the first time.

Excellent, so we know it's the server's fault. Really would have been odd to not have it in the server trace.

>> ..in order to rule out a mistake on my part with the two separate
>> runs (which prevents correlated analysis) I was just about to boot
>> the server back into 3.18.1 and re-run both client- and server-side
>> traces simultaneously. However I have to head out for a bit first;
>> will post that later today.
> 
> So this might still be interesting, but it's not a high priority.

Then I guess I'll better keep my feet still and don't muddle the waters further, looks like you found what you need. If you still need it just holler.

Let me know if there's anything I can do to help/patch/test!

thanks
Holger
