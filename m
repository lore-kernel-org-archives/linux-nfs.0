Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46820 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273Ab2HUVBX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 17:01:23 -0400
Date: Tue, 21 Aug 2012 17:01:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: parafin <parafin@paraf.in>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server misbehaving (nfsd eats CPU and returns no data)
Message-ID: <20120821210116.GB18637@fieldses.org>
References: <20120508024419.03e585f2@darkhorse.paraf.in>
 <20120821174355.GB15958@fieldses.org>
 <20120821225423.7465a987@darkhorse.paraf.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821225423.7465a987@darkhorse.paraf.in>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 10:54:23PM +0400, parafin wrote:
> I somewhat mitigated the problem by mount option timeo=10, but this
> issue still heavily affects NFS throughput. So yes, I'm willing to test,
> just have to find some free time to do it. I will report as soon as I
> get results.

OK, thanks.

> Thanks for reply, I thought my message was lost forever :)

In general feel free to retry every now and then (like after a week or
so, not every day please!) if you get ignored.  We all get overloaded an
drop things occasionally.

--b.

> 
> On Tue, 21 Aug 2012 13:43:55 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Are you still willing to test patches?  If so, this would be worth a
> > try:
> > 
> > 	http://marc.info/?l=linux-nfs&m=134550227125610&w=2
> > 
> > >From a quick look at your logs it looks likely to address the same
> > problem.
> > 
> > Apologies for the delayed response, we finally just happened to get the
> > clue necessary to make the problem obvious....
> > 
> > --b.
> > 
> > On Tue, May 08, 2012 at 02:44:19AM +0400, parafin wrote:
> > > Hello.
> > > I'm having a problem with my NFS share. It's been present for some time
> > > now, kernel versions got upgraded, setup has been changed, but since I
> > > can't remember for sure when it started, I'll just describe my current
> > > configuration. But first the problem itself.
> > > Periodically (I would say every GB of data or so) reads from NFS share
> > > hang during which nfsd kernel thread on server eats CPU but no data
> > > gets sent to the client. After a minute everything comes to norm again
> > > (no action on my part is required). First thing I did to debug this is
> > > I enabled verbose output in all userspace daemons both on client and
> > > server - it produced no output whatsoever during the problematic period
> > > of time. Next I dumped network traffic on TCP port 2049 both on client
> > > and server - there was no packet drops or any other strange stuff,
> > > except that client restarted the TCP connection to 2049 port after a
> > > minute of silence from server (which resulted in data flowing again).
> > > This was confirmed by kernel debug output from client (echo 65535 | tee
> > > nfs_debug nfsd_debug nlm_debug rpc_debug) - NFS client sent a server
> > > READ request with 60 seconds timeout, timeout was reached and resulted
> > > in dropping and restarting of NFS TCP connection. So this points to NFS
> > > server kernel code. Kernel debug output on server is quite large and
> > > spikes during the hangs - I've attached deduplicated (by hand) version
> > > of it to this email. I couldn't find anything strange in there, but I
> > > don't understand most of it anyway.
> > > My current setup - both server and client are Linux 3.3.3, NFSv4 with
> > > sec=krb5, it runs through local network 192.168.0.0/24 with no
> > > firewalls (client has iptables disabled in kernel, server ACCEPTs
> > > everything from internal interface). Client uses Wi-Fi, server -
> > > Ethernet with VLANs, so traffic goes through AP. But since network dumps
> > > on server and client are the same, network configuration IMHO is
> > > irrelevant, I just added it for fullness of description. Most common
> > > usage (and test case) of this NFS share is watching some videos using
> > > mplayer. Underlying filesystem is XFS (though ext4 is used for other
> > > shares on the same server).
> > > I'm ready to provide additional information or test some patches, since
> > > this problem is quite annoying (and IMHO got worse with time).
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
