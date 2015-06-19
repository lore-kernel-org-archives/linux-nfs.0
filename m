Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35574 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbFSBhL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 21:37:11 -0400
Received: by igbzc4 with SMTP id zc4so4482796igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 18:37:10 -0700 (PDT)
Date: Thu, 18 Jun 2015 21:37:02 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>, bfields@fieldses.org
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150618213702.33f64b20@synchrony.poochiereds.net>
In-Reply-To: <20150618210843.4b09c31c@grimm.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Jun 2015 21:08:43 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu, 18 Jun 2015 18:50:51 -0400
> Jeff Layton <jlayton@poochiereds.net> wrote:
>  
> > The interesting bit here is that the sockets all seem to connect to port
> > 55201 on the remote host, if I'm reading these traces correctly. What's
> > listening on that port on the server?
> > 
> > This might give some helpful info:
> > 
> >     $ rpcinfo -p <NFS servername>
> 
> # rpcinfo -p wife
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  34243  status
>     100024    1   tcp  34498  status
> 
> # rpcinfo -p localhost
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  38332  status
>     100024    1   tcp  52684  status
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100227    2   tcp   2049
>     100227    3   tcp   2049
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100227    2   udp   2049
>     100227    3   udp   2049
>     100021    1   udp  53218  nlockmgr
>     100021    3   udp  53218  nlockmgr
>     100021    4   udp  53218  nlockmgr
>     100021    1   tcp  49825  nlockmgr
>     100021    3   tcp  49825  nlockmgr
>     100021    4   tcp  49825  nlockmgr
>     100005    1   udp  49166  mountd
>     100005    1   tcp  48797  mountd
>     100005    2   udp  47856  mountd
>     100005    2   tcp  53839  mountd
>     100005    3   udp  36090  mountd
>     100005    3   tcp  46390  mountd
> 
> Note, the box has been rebooted since I posted my last trace.
> 

Ahh pity. The port has probably changed...if you trace it again maybe
try to figure out what it's talking to before rebooting the server?

> > 
> > Also, what NFS version are you using to mount here? Your fstab entries
> > suggest that you're using the default version (for whatever distro this
> > is), but have you (e.g.) set up nfsmount.conf to default to v3 on this
> > box?
> > 
> 
> My box is Debian testing (recently updated).
> 
> # dpkg -l nfs-*
> 
> ii  nfs-common     1:1.2.8-9    amd64        NFS support files common to clien
> ii  nfs-kernel-ser 1:1.2.8-9    amd64        support for NFS kernel server
> 
> 
> same for both boxes.
> 
> nfsmount.conf doesn't exist on either box.
> 
> I'm assuming it is using nfs4.
> 

(cc'ing Bruce)

Oh! I was thinking that you were seeing this extra port on the
_client_, but now rereading your original mail I see that it's
appearing up on the NFS server. Is that correct?

So, assuming that this is NFSv4.0, then this port is probably bound
when the server is establishing the callback channel to the client. So
we may need to look at how those xprts are being created and whether
there are differences from a standard client xprt.

-- 
Jeff Layton <jlayton@poochiereds.net>
