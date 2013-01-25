Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay1.sgi.com ([192.48.179.29]:49843 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab3AYWCu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 17:02:50 -0500
Date: Fri, 25 Jan 2013 16:02:49 -0600
From: Ben Myers <bpm@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jim Rees <rees@umich.edu>
Subject: Re: sunrpc: socket buffer size tuneable
Message-ID: <20130125220249.GY30652@sgi.com>
References: <20130125192935.GA32470@sgi.com>
 <20130125202107.GD29596@fieldses.org>
 <20130125203507.GW30652@sgi.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91833BF5A@sacexcmbx05-prd.hq.netapp.com>
 <20130125212106.GH29596@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91833BFAB@sacexcmbx05-prd.hq.netapp.com>
 <20130125213503.GI29596@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91833BFFE@sacexcmbx05-prd.hq.netapp.com>
 <20130125215712.GJ29596@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130125215712.GJ29596@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,
	
On Fri, Jan 25, 2013 at 04:57:12PM -0500, J. Bruce Fields wrote:
> On Fri, Jan 25, 2013 at 09:45:12PM +0000, Myklebust, Trond wrote:
> > > -----Original Message----- From: J. Bruce Fields
> > > [mailto:bfields@fieldses.org] Sent: Friday, January 25, 2013 4:35 PM
> > > To: Myklebust, Trond Cc: Ben Myers; Olga Kornievskaia;
> > > linux-nfs@vger.kernel.org; Jim Rees Subject: Re: sunrpc: socket
> > > buffer size tuneable
> > > 
> > > On Fri, Jan 25, 2013 at 09:29:09PM +0000, Myklebust, Trond wrote:
> > > > > -----Original Message----- From: J. Bruce Fields
> > > > > [mailto:bfields@fieldses.org] Sent: Friday, January 25, 2013
> > > > > 4:21 PM To: Myklebust, Trond Cc: Ben Myers; Olga Kornievskaia;
> > > > > linux-nfs@vger.kernel.org; Jim Rees Subject: Re: sunrpc: socket
> > > > > buffer size tuneable
> > > > >
> > > > > On Fri, Jan 25, 2013 at 09:12:55PM +0000, Myklebust, Trond
> > > > > wrote:
> > > >
> > > > > > Why is it not sufficient to clamp the TCP values of 'snd' and
> > > > > > 'rcv' using
> > > > > sysctl_tcp_wmem/sysctl_tcp_rmem?
> > > > > > ...and clamp the UDP values using
> > > > > sysctl_[wr]mem_min/sysctl_[wr]mem_max?.
> > > > >
> > > > > Yeah, I was just looking at that--so, Ben, something like:
> > > > >
> > > > > 	echo "1048576 1048576 4194304"
> > > > > 	>/proc/sys/net/ipv4/tcp_wmem
> > > > >
> > > > > But I'm unclear on some of the details: do we need to set the
> > > > > minimum or only the default?  And does it need any more
> > > > > allowance for protocol overhead?
> > > >
> > > > I meant adding a check either to svc_sock_setbufsize or to the 2
> > > > call-sites
> > > that enforces the above limits.
> > > 
> > > I lost you.
> > > 
> > > It's not svc_sock_setbufsize that's setting too-small values, if
> > > that's what you mean.
> > > 
> > 
> > I understood that the problem was svc_udp_recvfrom() and
> > svc_setup_socket() were using negative values in the calls to
> > svc_sock_setbufsize().  Looking again at svc_setup_socket(), I don't
> > see how that could do so, but svc_udp_recvfrom() definitely has
> > potential to cause damage.
> 
> Right, the changelog was confusing, the problem they're actually hitting
> is with tcp.  Looks like tcp autotuning is decreasing the send buffer
> below the size we requested in svc_sock_setbufsize().

echo "1048576 1048576 4194304" > /proc/sys/net/ipv4/tcp_wmem 

Seems to have been effective.  I'll be toasting to you gents tonight.

I think it would be good if the server enforced a setting that is large enough.

Thanks,
	Ben
