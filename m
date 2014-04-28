Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:52053 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453AbaD1Kfk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Apr 2014 06:35:40 -0400
Date: Mon, 28 Apr 2014 06:35:30 -0400
From: Jim Rees <rees@umich.edu>
To: Dean <seattleplus@gmail.com>
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
Message-ID: <20140428103530.GA19612@umich.edu>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
 <20140424031216.GA18817@umich.edu>
 <CALXu0UdsUk2bSWUzOXLHJ1FKtnZMyo0OHJSj=0hQpwwHVu52zw@mail.gmail.com>
 <535DE5CE.7050600@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <535DE5CE.7050600@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dean wrote:

  On 4/24/14, 10:22 AM, Cedric Blancher wrote:
  >On 24 April 2014 05:12, Jim Rees <rees@umich.edu> wrote:
  >>Cedric Blancher wrote:
  >>
  >>   Are there any options to improve the Linux NFSv4 performance over a
  >>   high latency connection?
  >>
  >>We did some work along these lines at CITI years ago. As I remember, the
  >>main thing was to increase net.ipv4.tcp_[rw]mem on the server side, because
  >>tcp auto-tuning was being defeated. This may be less of an issue with your
  >>work load, which sounds like many small files rather than one big one.  In
  >>theory, NFSv4 delegations should help, but I don't know how well that works.
  
  Along with Jim's work, we followed up with a fair bit, but in general we
  found that nfs clients just can't do well over large rtt due to the slow
  window ramp up time and adverse reaction to packet loss.  Unfortunately the
  only way to overcome these issues (other than using a custom udp protocol
  which isn't supported) is to use multiple TCP connections, which is what we
  do by  using multiple nodes....

Yeah, at the time I think reno was the default congestion, and you need
something with a faster rampup. I believe cubic is default now and it's
pretty good but still not good enough. Andy Adamson did some work too,
making the number of rpc slots dynamic, and I think that's in the kernel
now.

If you've got a very high speed network, like say 10Gb with >100 msec, you
may need to do some tuning in the ethernet driver, increasing ring buffer
sizes and so on. Your congestion window can grow to hundreds of MB in this
case.

And there's no getting around that nfs is fairly chatty.
