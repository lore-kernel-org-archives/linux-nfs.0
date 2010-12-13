Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39890 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754810Ab0LMTrw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 14:47:52 -0500
Subject: Re: Side effects of having NFSv4 mounted over udp
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Thomas Haynes <thomas@netapp.com>,
        DENIEL Philippe <philippe.deniel@cea.fr>, linux-nfs@vger.kernel.org
In-Reply-To: <20101213191634.GB2230@fieldses.org>
References: <4D05CF50.1010305@cea.fr>
	 <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com>
	 <20101213191634.GB2230@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 13 Dec 2010 14:47:35 -0500
Message-ID: <1292269655.8795.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-12-13 at 14:16 -0500, J. Bruce Fields wrote:
> On Mon, Dec 13, 2010 at 01:04:28PM -0600, Thomas Haynes wrote:
> > 
> > On Dec 13, 2010, at 1:46 AM, DENIEL Philippe wrote:
> > 
> > > Hi,
> > > 
> > > I know NFSv4 is definitely a connection oriented protocol, but noting prevent from using "mount -t nfs4 -o proto=udp <...>". Using TCP instead of UDP could be of great interest, especially in a HPC context where thousands of clients will operate at the same time. If a nfs mount point is made over udp, what would be the side effects ? I tried to run the connectathon on such a udp based mount point and I could find no errors. Is NFSv4/UDP a suitable solution ? Or does it make no sense to use udp ?
> > 
> > 
> > You might find that some implementations have UDP disabled and it might then make
> > it hard to triage what is going on.
> > 
> > I believe both NetApp's OnTap and Oracle's Solaris have it turned off.
> 
> The Linux server allows it, but I've been considering that a
> (low-priority) bug, so it wouldn't be safe to assume it will continue
> working.
> 
> That aside, if you have a perfect network, NFSv4.0 at least will
> probably work.  (Not 4.1 since backchannel setup will fail?)
> 
> Are you really sure that you can't make tcp scale to thousands of
> clients?

Maybe SCTP would be the way to go then? We've often talked about it over
the years, but nobody has yet (to my knowledge) written an ONC RPC
transport for it.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

