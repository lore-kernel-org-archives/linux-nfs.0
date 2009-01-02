Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53664 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813AbZABA32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jan 2009 19:29:28 -0500
Date: Thu, 1 Jan 2009 19:29:24 -0500
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with Mac clients mounting a Linux server behind a
	firewall
Message-ID: <20090102002924.GD31840@fieldses.org>
References: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com> <494FC625.4040207@moving-picture.com> <20081222172309.GO4191@fieldses.org> <a92ebfd90812221236g7250f256n5b58b5ff5ce47403@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a92ebfd90812221236g7250f256n5b58b5ff5ce47403@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 22, 2008 at 08:36:12PM +0000, James Pearson wrote:
> 2008/12/22 J. Bruce Fields <bfields@fieldses.org>:
> > On Mon, Dec 22, 2008 at 04:53:57PM +0000, James Pearson wrote:
> >
> >>> Is there anything that NFS server-wise that could be cause the server
> >>> to attempt to contact clients in this way?
> >>
> >> Running wireshark over the tcpdump output, all these portmap calls are like:
> >>
> >> User Datagram Protocol, Src Port: 51947 (51947), Dst Port: sunrpc (111)
> >> Remote Procedure Call, Type:Call XID:0xacd4150f
> >> Portmap GETPORT Call NLM(100021) Version:4 UDP
> >>     [Program Version: 2]
> >>     [V2 Procedure: GETPORT (3)]
> >>     Program: NLM (100021)
> >>     Version: 4
> >>     Proto: UDP (17)
> >>     Port: 0
> >>
> >> Why would an NFS server need to initiate a call to the lockd process on
> >> a (MacOS) client?
> >
> > The communication between lockd's is 2-way, so that, for example,
> > servers can notify clients when locks are available.  Also, the server's
> > statd needs to contact the clients so it can ask the clients to notify
> > it when the clients reboot (and hence when their file locks should be
> > released).  And similarly the server needs to be able to notify the
> > clients when it reboots, so the client can reclaim any locks it
> > previously held.
> >
> > So your firewall settings are a problem.  But, obviously, we should be
> > handling this more gracefully on the server.
> 
> Thanks for the explanation - however, I never come across this
> requirement before with NFS servers behind firewalls - for example,
> RedHat's documentation at <http://kbase.redhat.com/faq/docs/DOC-3259>
> says the usual stuff about fixing the ports of various portmap
> services for the server and opening those ports for traffic to the
> server through the firewall - but no mention of the server needing to
> talk to the portmapper and lockd on the clients ... and I can't see
> how this would work as the portmapper port and any possible lockd port
> will have to be open on the firewall from server to all clients ...
> 
> Also, it is strange that this problem only happens with MacOS clients
> - I've never see the server trying to talk to Linux clients in this
> way. So I guess it is something that the MacOS clients do differently

There may be a bug keeping the server from clearing out old statd
entries?  If so perhaps it's just that every client only gets monitored
once, and that that happened longer ago for the linux clients than the
mac clients?  Our recovery code needs some work.

I can't think of any reason the client implementation would matter,
unless perhaps the mac clients just aren't doing monitored locking at
all.

> Is there any way I can configure the server to ignore locking
> completely? e.g. turn off statd?

That might work.  It might end up giving the applications that are using
locking unexpected errors.

Better might be to have the clients to mount with the "nolock" option.
Then the client will pretend to do locking but without actually
acquiring locks on the server, which may of course be dangerous
depending on how the locks are being used....

--b.
