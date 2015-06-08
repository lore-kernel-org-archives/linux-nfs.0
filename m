Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:32851 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbFHRr6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 13:47:58 -0400
Received: by qkhg32 with SMTP id g32so81764654qkh.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2015 10:47:57 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [BUG] nfs3 client stops retrying to connect
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20150608171006.GA13396@bender.morinfr.org>
Date: Mon, 8 Jun 2015 13:50:47 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Message-Id: <21A8A567-1EB4-4E3A-8DB8-BD07212044D0@gmail.com>
References: <20150521012155.GA19680@bender.morinfr.org> <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com> <20150604200621.GA10335@bender.morinfr.org> <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com> <20150604221404.GA20363@bender.morinfr.org> <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com> <20150608171006.GA13396@bender.morinfr.org>
To: Guillaume Morin <guillaume@morinfr.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2015, at 1:10 PM, Guillaume Morin <guillaume@morinfr.org> wrote:

> Chuck,
> 
> On 04 Jun 22:57, Chuck Lever wrote:
>>> I am 100% sure that XPRT_CONNECTING is the issue because 1) the state
>>> had the flag up 2) there was absolutley no nfs network traffic between the
>>> client and the server 3) I "unfroze" the mounts by clearing it manually.
>>> 
>>> xs_tcp_cancel_linger_timeout, I think, is guaranteed to clear the flag.
>> 
>> I'm speculating based on some comments in the git log, but what if
>> the transport never sees TCP_CLOSE, but rather gets an error_report
>> callback instead?
> 
> I don't think that could be it because xs_tcp_setup_socket() does the
> connecting and is clearing the bit in all cases so at the time you would get
> a TCP_CLOSE it would have been cleared a while ago.

The linger timer is started by FIN_WAIT1 or LAST_ACK, and
xs_tcp_schedule_linger_timeout sets XPRT_CONNECTING and
XPRT_CONNECTION_ABORT.

At a guess there could be a race between xs_tcp_cancel_linger_timeout
and the connect worker clearing those flags.

> So that's why I thought the best explanation was finding a place where
> the worker task running xs_tcp_setup_socket() is cancelled and the bit
> not cleared.  This is how I found xs_tcp_close()
> 
>>> Either the callback is canceled and it clears the flag or the callback
>>> will do it.  I am not sure how this could leave the flag set but I am
>>> not familiar with this code, so I could totally be missing something
>>> obvious.
>>> 
>>> xs_tcp_close() is the only thing I have found which cancels the callback
>>> and does not clear the flag.
>> 
>> How would xs_tcp_close() be invoked?
> 
> TBH I do not know.  It's the close() method of the xprt so I am assuming
> there are a few places where it could be.  But I am not familiar with
> the code base..

AFAICT ->close is invoked when the transport is being shut down, in other
words at umount time. It is also invoked when the autoclose timer fires.

Autoclose is simply a mechanism for reaping NFS sockets that are idle.
I think the timer is 5 or 6 minutes.

Autoclose won’t fire if there is frequent work being done on the mount
point. If this is related to autoclose, then the workload on the client
might need to be sparse (NFS requests only every few minutes or so) to
reproduce it.

For example, autoclose fires and tries to shut down the socket after the
server is no longer responding.

> We had to move an nfs server on friday and I got a few machines that had
> the same issue again…

That suggests one requirement for your reproducer: after clients have
mounted it, the NFS server needs to be fully down for an extended period.

Since some clients recovered, I assume the server retained its IP address.
Did the network route change?

--
Chuck Lever
chucklever@gmail.com



