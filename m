Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58879 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933221AbcAKSrT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jan 2016 13:47:19 -0500
Date: Mon, 11 Jan 2016 13:47:18 -0500
To: Robb Barrows <rbarr138@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v4, are special steps required for uid/gid to work, even if
 they are the same on server and client?
Message-ID: <20160111184718.GB31946@fieldses.org>
References: <CAOHJ0jQyGD=RHCNSTSsOYWCy=o4ryw2X2NCcqs2DmMrXRSFdGg@mail.gmail.com>
 <20160108202357.GE5031@fieldses.org>
 <loom.20160108T220444-687@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20160108T220444-687@post.gmane.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2016 at 10:52:12PM +0000, Robb Barrows wrote:
> J. Bruce Fields <bfields@...> writes:
> 
> > > So my real question is why cant user:user create a file in 
> /test/chmod775 ?
> > 
> > Hm, and chmod775 should permit write to members of common, and user is a
> > member of common on both client and server (and names and uids are the
> > same on both).
> > 
> > I'm not seeing the explanation....
> > 
> > I think the next thing I'd do would be get a network trace:
> > 
> > 	1. run "tcpdump -s0 -wtmp.pcap"
> > 	2. try the failed "touch /test/chmod755/file"
> > 	3. kill the tcpdump
> > 
> > Then run "wireshark tmp.pcap" and look at the result.  If this is v4
> > thee should be an OPEN call in there that tries to create "file", with
> > the server replying with an error.
> > 
> > It'd be especially interesting to look at the rpc header on that call,
> > specifically the credential, which should include a list of gid's (with
> > 20000 being one of those gid's).
> > 
> 
> I did this and indeed 20000 was not in the list of "Auxiliary GIDs" of the 
> rpc header credentials as it should of been.  A reboot fixed this, so now it 
> works. 
> 
> I had restarted the terminal but it looks since I had other sessions logged 
> in that wasn't enough to get the new gid to propogate, I should know better. 
> 
> Running
> # sudo newgrp common
> Probably would of fixed it for me, as it adds you to the group without 
> requiring logging out, I'll never trust the "groups" command again :)
> 
> Thank you helping me find the issue.

Ah, I hadn't thought of that, makes sense, thanks for reporting the
solution.

--b.
