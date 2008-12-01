From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] gssd:  unblock DNOTIFY_SIGNAL in case it was blocked.
Date: Mon, 01 Dec 2008 14:29:01 -0500
Message-ID: <49343AFD.7090709@RedHat.com>
References: <18712.46537.9006.490726@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42160 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727AbYLATbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2008 14:31:37 -0500
In-Reply-To: <18712.46537.9006.490726-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> I have a situation where rpc.gssd appears to not be working.
> Mount attempts which need to communicate with it block.
> 
> I've narrowed down the problem to that fact that all realtime signals
> have been blocked.  This means that DNOTIFY_SIGNAL (which is a
> realtime signal) is never delivered, so gssd never rescans the
> rpc_pipe/nfs directory.
> 
> I haven't figured out why the signals are blocked yet, but having
> rpc.gssd fail mysteriously in that situation isn't pleasant.
> 
> So I wonder what people think of the following patch.  It simply
> unblocks the signal.  Alternately we can check if it is blocked and
> warn - I'm not really sure of the significance of blocking all these
> signals.  Maybe it's wrong to just unblock them.
> 
> 
> As an aside, maybe we could change gssd_run to use "ppoll" rather than
> "poll".  Then it would not have to wake up every 500msec to see if it
> missed a signal. We would probably have to check kernel version was at
> least 2.6.16....
> 
Committed...

steved.
