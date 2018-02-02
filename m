Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752069AbeBBO4w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 09:56:52 -0500
Subject: Re: Question about random UDP port on rpcbind 0.2.3
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
 <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
 <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com>
 <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <9f10b181-4dfa-c40c-3f66-c29ce3b5dd42@RedHat.com>
Date: Fri, 2 Feb 2018 09:56:51 -0500
MIME-Version: 1.0
In-Reply-To: <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I took sometime to verify this crusty code actually works... It does.
 
On 01/31/2018 03:09 PM, Chuck Lever wrote:
> 
>>>
>>> We should change rpcbind to retain CAP_NET_BIND_SERVICE, so that
>>> it doesn't have to hold onto that port indefinitely. It should
>>> be able to bind to an outgoing privileged port whenever it needs
>>> one.
You suggesting we do something similar to nsm_clear_capabilities()?

>> Or we just avoid know ports like sm-notify does.
> 
> statd, you mean. It should also retain CAP_NET_BIND_SERVICE instead
> of what it does now, IMO.
Well I was talking about the code in sm-notify.c but yes statd
does make the same call to getservbyport().

> 
> Note that in both of these cases, that long-lived port is never going
> to be used, going forward: 
> 
> - no one uses the rpcbind port-forward service that I know of
Has any ever use it?? Why did it even exist?? 

> 
> - NLM is going out of style
Not fast enough! ;-) 

> 
> If we can make these two cases on-demand instead, so much the better,
> I say. As Mr. Talpey pointed out recently, the only long-lived
> privileged ports we should see on Linux are well-known service
> listeners, not outgoing ports.
I guess this the patch Scott has posted... After a quick 
look there appears to be a lot changed which is bit
worrisome... 

> 
> A fix for rpcbind might be to add a cmd-line flag to enable the
> rpcbind forwarding service, and have the service default to disabled.
I would rather have it auto-magically work ;-) 

> I'm not sure why rpcbind would list an outgoing port in it's portmap
> menu. Are you sure that this is the forwarding reflector port?
> 
Yes... the listening fd is created by create_rmtcall_fd()
This is not the first time people have complained about
rpbind's rogue listening port :-( 

steved.


