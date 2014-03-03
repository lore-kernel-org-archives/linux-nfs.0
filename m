Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:61845 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754982AbaCCXCL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 18:02:11 -0500
Received: by mail-ig0-f179.google.com with SMTP id t19so915023igi.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 15:02:11 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH/RFC] Add simple backoff logic when reconnecting to a server that recently initiated a connection close
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140303221053.GB45663@tonberry.usersys.redhat.com>
Date: Mon, 3 Mar 2014 18:02:08 -0500
Cc: Layton Jeff <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <210894A7-21A1-4F59-99F7-F5D28F8D4E06@primarydata.com>
References: <20140228222956.GA1544@tonberry.usersys.redhat.com> <20140303111352.736a7268@tlielax.poochiereds.net> <977F590C-0AF9-4B7F-B1FF-C10777987887@primarydata.com> <20140303221053.GB45663@tonberry.usersys.redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 3, 2014, at 17:10, Scott Mayhew <smayhew@redhat.com> wrote:

> On Mon, 03 Mar 2014, Trond Myklebust wrote:
> 
>> 
>> On Mar 3, 2014, at 11:13, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Fri, 28 Feb 2014 17:29:56 -0500
>>> Scott Mayhew <smayhew@redhat.com> wrote:
>>> 
>>>> From 2e3902fc0c66bda360a8e40e3e64d82e312a20d4 Mon Sep 17 00:00:00 2001
>>>> From: Scott Mayhew <smayhew@redhat.com>
>>>> Date: Fri, 28 Feb 2014 15:23:50 -0500
>>>> Subject: [PATCH] sunrpc: reintroduce xprt->shutdown with a new purpose (option
>>>> 2)
>>>> 
>>>> If a server is behaving pathologically and accepting our connections
>>>> only to close the socket on the first RPC operation it receives, then
>>>> we should probably delay when trying to reconnect.
>>>> 
>>>> This patch reintroduces the xprt->shutdown field (this time as two
>>>> bits).  Previously this field was used to indicate that the transport
>>>> was in the process of being shutdown, but now it will just be used to
>>>> indicate that a shutdown was initiated by the server.
>>>> 
>>>> If the server closes the connection 3 times without us having received
>>>> an RPC reply in the interim, then we'll delay before attempting to
>>>> connect again.
>>>> ---
>>>> include/linux/sunrpc/xprt.h |  3 ++-
>>>> net/sunrpc/clnt.c           |  2 ++
>>>> net/sunrpc/xprtsock.c       | 13 +++++++++++++
>>>> 3 files changed, 17 insertions(+), 1 deletion(-)
>>>> 
>>> 
>>> This patch seems a little more reasonable than the other one if only
>>> because it shouldn't cause artificial delays when there is some
>>> temporary hiccup that causes the server to shut down the connection.
>>> 
>>> That said, this seems to be squarely a server-side bug so I'm not sure
>>> we ought to go to any great lengths to work around it.
>> 
>> So this is about a broken server that accepts connection requests and then immediately closes them?
> 
> That's correct.
> 
>> If so, then I agree with Jeff, it really isn?t something we need to fix on the client.
> 
> Not even for the sake of 'politeness' (for lack of a better word)?  This
> was in a grid environment and there were apparently a few thousand clients
> doing this, not just a single client.
> 

No. If the problem is a broken server, then we fix the server. No politeness needed… :-)

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

