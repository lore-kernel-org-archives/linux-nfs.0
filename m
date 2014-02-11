Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885AbaBKQcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 11:32:16 -0500
Date: Tue, 11 Feb 2014 11:32:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "McAninley, Jason" <jmcaninl@harris.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question regard NFS 4.0 buffer sizes
Message-ID: <20140211163215.GA19599@fieldses.org>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
 <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 11, 2014 at 03:01:39PM +0000, McAninley, Jason wrote:
> Thanks for the reply, Bruce.
> 
> > Are you using UDP or TCP?
> 
> TCP.
> 
> > And what do you mean by "maximum packet size"?
> 
> I'm generally referring to the Frame size (e.g. 32,626) and/or the TCP packet size (e.g. 32560) - The former being the size of the latter plus the ethernet/IP headers.
> 
> > To see if the maximum rsize/wsize is being used you'd need to look for
> > the length of the data in a READ reply or WRITE call.
> 
> Right. When I check the contents of a WRITE RPC, I see "Data" length of 32768 (32k).
> 
> My understanding is that setting {r,w}size doesn't guarantee that will be the agreed-upon value. Apparently one must check the value in /proc. I have verified this by checking the value of /proc/XXXX/mounts, where XXXX is the pid for nfsv4.0-svc on the client. It is set to a value >32K.

I don't think that actually takes into account the value returned from
the server.  If you watch the mount in wireshark early on you should see
it query the server's rsize and wsize, and you may find that's less.

> > What actual problem are you trying to solve?  (Is your read or write
> > bandwidth lower than you expected?)
> 
> I am trying to maximize throughout within a parallel processing cluster. We have GigE connections within our closed network and I would like to ensure we are fully utilizing our bandwidth. Additionally, I find a lot of information online (that is not outdated) suggests various Kernel/OS/NFS settings without giving details for why the settings should be modified.

If you haven't already I'd first recommend measuring your NFS read and
write throughput and comparing it to what you can get from the network
and the server's disk.  No point tuning something if it turns out it's
already working.

--b.

> 
> Upon changing the rsize/wsize, I would have expected to see a change in the packet/payload size, but I do not.
> 
> -Jason
