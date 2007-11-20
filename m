From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] rpc.statd
Date: Tue, 20 Nov 2007 21:52:30 +1100
Message-ID: <18242.48238.634499.917550@notabene.brown>
References: <1b378070711191506o14ce99feo37c2a75bfdc4e47e@mail.gmail.com>
	<20071119202308.3f2430ec@tleilax.poochiereds.net>
	<1b378070711191806v55fb915fnb2949a8aca03c52@mail.gmail.com>
	<20071120053929.6099a595@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: Shiney James <shineyjames@gmail.com>, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuQia-0004tm-RS
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 02:52:36 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IuQif-0005wi-Jx
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 02:52:43 -0800
In-Reply-To: message from Jeff Layton on Tuesday November 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday November 20, jlayton@redhat.com wrote:
> On Mon, 19 Nov 2007 18:06:53 -0800
> "Shiney James" <shineyjames@gmail.com> wrote:
> 
> > Thanks a lot for the information. I would like to know if there is a
> > way to configure this port?
> > Can a port already specified in /etc/services be used for the purpose?
> > 
> 
> I don't think so. I think it just uses bindresvport to find the first
> available port that's not designated for a service.

I think "--outgoing-port" will do what you want.
I seem to recall that it uses the same port for all outgoing messages.

We really should fix the "statd" man page:

       -o, --outgoing-port port
              specify a port for  rpc.statd  to  send  outgoing  status
              requests from.  By default, rpc.statd will ask portmap(8)
              to assign it a port number.  As of this writing, there is
              not a standard port number that portmap always or usually
              assigns.  Specifying a port may be useful when implement‐
              ing a firewall.


portmap(8) has no part at all in assigning port numbers...


NeilBrown



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

