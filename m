From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [grumble] connected UDP sockets [grumble] Solaris [grumble]
Date: Thu, 23 Oct 2008 12:05:49 -0400
Message-ID: <955D3633-8CF0-44E6-B09B-05BA33A51AC9@oracle.com>
References: <18687.63003.966163.267177@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:51461 "EHLO
	rgminet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbYJWQai (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 12:30:38 -0400
Received: from rgminet11.oracle.com (rcsinet11.oracle.com [148.87.113.123])
	by rgminet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id m9NG7YrJ009658
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Oct 2008 16:07:36 GMT
In-Reply-To: <18687.63003.966163.267177-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 22, 2008, at Oct 22, 2008, 11:57 PM, Neil Brown wrote:
> The attentive reader of this mailing list may be aware that I was -
> some time ago - advocating using connected UDP sockets when UDP was
> used to contact the server during a mount. i.e. to talk to portmap and
> mountd.
>
> The benefit of this is that errors reported by ICMP (e.g. host
> unreachable / port unreachable) are reported to the application with
> connected sockets, whereas unconnected sockets need to wait for a
> timeout.
>
> I just discovered that there is a problem with this.  It involves
> multihomed hosts and certain non-Linux operating systems such as
> Solaris (I don't know which version(s)).
>
> In one particular case, the UDP request (portmap lookup I assume) was
> sent from a Linux client to a Solaris server and the reply promptly
> came back from a different IP address (presumably the address of the
> interface that Solaris wanted to route through to get to the client).
> Linux replied to this with an ICMP error.  It couldn't send the reply
> to mount.nfs because mount.nfs had a connected UDP sockets that was
> connected to a different remote address.
>
> This is arguably a bug in Solaris.  It should reply with a source
> address matching the destination address of the request.  Linux hasn't
> had that bug for years.  But we probably still have to live with it.
>
> The conclusion is that if we use connected UDP sockets, we will get
> unnecessary timeout talking to certain multihomed hosts, and if we
> don't we will get unnecessary timeouts talking to certain hosts that
> don't support portmap on UDP (for example).

Ja, disappointing.

> I don't suppose there is a middle ground?  A semi-connected socket?
> Or we could have one of each and see which one gets a reply first?
> No, that's just yuck.
>
> Much as it pains me to say this, maybe we just need to treat UDP as
> legacy for all protocols (PORTMAP, MOUNT, NLM, NSM), not just NFS.
> None of these problems occur with TCP.  TCP does have a slightly
> higher overhead for simple transactions, but it is a cost that is
> unlikely to be noticeable in reality.

> Thoughts?

As many good things as there are about TCP, it has one major  
drawback:  it leaves a connection in CLOSE_WAIT for a long period  
(normally 120 seconds) after a normal socket close.  This ties up our  
port range on workloads that have to do one or just a few requests  
then close their socket.  We are slowly making headway on improving  
this situation (using non-privileged ports wherever practical, for  
instance) but it will take some time.

There are also still some common and reasonable configurations where  
TCP overhead (the 3-way handshake and tiny ACK packets) is  
significant.  For example, running in a virtual machine means a domain  
switch for every packet.

In my opinion the problem configuration you describe above is more  
rare than configurations that are helped by using connected UDP  
sockets.  (But don't ask me to back that up with real data).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
