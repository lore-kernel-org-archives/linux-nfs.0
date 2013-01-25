Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25499 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878Ab3AYV3L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2013 16:29:11 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jim Rees <rees@umich.edu>
Subject: RE: sunrpc: socket buffer size tuneable
Date: Fri, 25 Jan 2013 21:29:09 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91833BFAB@sacexcmbx05-prd.hq.netapp.com>
References: <20130125192935.GA32470@sgi.com>
 <20130125202107.GD29596@fieldses.org> <20130125203507.GW30652@sgi.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91833BF5A@sacexcmbx05-prd.hq.netapp.com>
 <20130125212106.GH29596@fieldses.org>
In-Reply-To: <20130125212106.GH29596@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Friday, January 25, 2013 4:21 PM
> To: Myklebust, Trond
> Cc: Ben Myers; Olga Kornievskaia; linux-nfs@vger.kernel.org; Jim Rees
> Subject: Re: sunrpc: socket buffer size tuneable
> 
> On Fri, Jan 25, 2013 at 09:12:55PM +0000, Myklebust, Trond wrote:

> > Why is it not sufficient to clamp the TCP values of 'snd' and 'rcv' using
> sysctl_tcp_wmem/sysctl_tcp_rmem?
> > ...and clamp the UDP values using
> sysctl_[wr]mem_min/sysctl_[wr]mem_max?.
> 
> Yeah, I was just looking at that--so, Ben, something like:
> 
> 	echo "1048576 1048576 4194304" >/proc/sys/net/ipv4/tcp_wmem
> 
> But I'm unclear on some of the details: do we need to set the minimum or
> only the default?  And does it need any more allowance for protocol
> overhead?

I meant adding a check either to svc_sock_setbufsize or to the 2 call-sites that enforces the above limits.

Trond
