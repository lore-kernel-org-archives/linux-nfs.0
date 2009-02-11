From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Wed, 11 Feb 2009 21:57:07 +0100
Message-ID: <20090211205707.GB9662@janus>
References: <20090211112318.GA29133@janus> <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus> <20090211203948.GD27686@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:53101 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756391AbZBKU5K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2009 15:57:10 -0500
In-Reply-To: <20090211203948.GD27686@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2009 at 03:39:48PM -0500, J. Bruce Fields wrote:
> On Wed, Feb 11, 2009 at 09:37:03PM +0100, Frank van Maarseveen wrote:
> > On Wed, Feb 11, 2009 at 03:35:55PM -0500, J. Bruce Fields wrote:
> > > On Wed, Feb 11, 2009 at 12:23:18PM +0100, Frank van Maarseveen wrote:
> > > > I'm sorry to inform you but... it seems that there is a similar problem
> > > > in the NLM subsystem as reported previously but this time it is triggered
> > > > when the grace time expires after a reboot.
> > > > 
> > > > Client and server run 2.6.27.14 + previous fix, NFSv3.
> > > > 
> > > > On the client there are three shells running:
> > > > 
> > > > 	while :; do lck -w /mnt/foo 2; done
> > > > 
> > > > The "lck" program is the same as posted before and it obtains an exclusive
> > > > write lock then waits 2 seconds in above invocation (there's probably an
> > > > "fcntl" command equivalent). After an orderly server reboot + grace time
> > > 
> > > How are you rebooting the server?
> > 
> > "reboot"
> 
> Could you watch the nfs/nlm/nsm traffic on reboot and make sure that the
> server is actually sending the reboot notification to the client, and
> that the client is trying to reclaim?  (Wireshark should make this all
> fairly clear.  But capture the traffic with tcpdump -s0 -wtmp.pcap and
> send it to me if you're having trouble interpreting it.)

Can't try it right now but tomorrow I can. However, I'm pretty sure at least
the reboot notification is there because:

1)	The issue happens too in a totally different NFS server setup which
	by definition invokes sm-notify in a script. This is the real use
	case.
2)	If not, then I would expect different behavior anyway compared to
	what I saw. A lost reboot notification is always possible but in
	that case the client(s) might end up holding more locks than the
	server, not the other way around as it is right now.

I'll make a capture.

-- 
Frank
