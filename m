Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59250 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753949AbeC1Pry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 11:47:54 -0400
Date: Wed, 28 Mar 2018 11:47:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Regarding client fairness
Message-ID: <20180328154754.GB3038@fieldses.org>
References: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
 <20180328145406.GA2641@fieldses.org>
 <20180328145930.GB2641@fieldses.org>
 <4abd5e4f-2992-730b-8d44-5e611a3a2451@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4abd5e4f-2992-730b-8d44-5e611a3a2451@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 06:35:53PM +0300, Antti Tönkyrä wrote:
> On 2018-03-28 17:59, J. Bruce Fields wrote:
> >On Wed, Mar 28, 2018 at 10:54:06AM -0400, bfields wrote:
> >>On Wed, Mar 28, 2018 at 02:04:57PM +0300, daedalus@pingtimeout.net wrote:
> >>>I came across a rather annoying issue where a single NFS client
> >>>caused resource starvation for NFS server. The server has several
> >>>storage pools which are used, in this particular case a single
> >>>client did fairly large read requests and effectively ate all nfsd
> >>>threads on the server and during that other clients were getting
> >>>hardly any I/O through to the other storage pool which was
> >>>completely idle.
> >>What version of the kernel are you running on your server?
> 4.15.10 on the system I am testing on.
> >I'm thinking that if it includes upstream 637600f3ffbf "SUNRPC: Change
> >TCP socket space reservation" (in upstream 4.8), then you may want to
> >experiment setting the sunrpc.svc_rpc_per_connection_limit module
> >parameter added in ff3ac5c3dc23 "SUNRPC: Add a server side
> >per-connection limit".
> >
> >You probably want to experiment with values greater than 0 (the default,
> >no limit) and the number of server threads.
> That helps for the client slowing down the whole server, thanks for
> the tip! Of course this doesn't help with the case of client
> accessing 2 different shares on the same server but that is
> something I can work around.

I thought the Linux client shared a single connection in that case, but
I could be wrong.

--b.
