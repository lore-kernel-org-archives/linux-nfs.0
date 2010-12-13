Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50025 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470Ab0LMTQo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 14:16:44 -0500
Date: Mon, 13 Dec 2010 14:16:35 -0500
To: Thomas Haynes <thomas@netapp.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>, linux-nfs@vger.kernel.org
Subject: Re: Side effects of having NFSv4 mounted over udp
Message-ID: <20101213191634.GB2230@fieldses.org>
References: <4D05CF50.1010305@cea.fr>
 <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 13, 2010 at 01:04:28PM -0600, Thomas Haynes wrote:
> 
> On Dec 13, 2010, at 1:46 AM, DENIEL Philippe wrote:
> 
> > Hi,
> > 
> > I know NFSv4 is definitely a connection oriented protocol, but noting prevent from using "mount -t nfs4 -o proto=udp <...>". Using TCP instead of UDP could be of great interest, especially in a HPC context where thousands of clients will operate at the same time. If a nfs mount point is made over udp, what would be the side effects ? I tried to run the connectathon on such a udp based mount point and I could find no errors. Is NFSv4/UDP a suitable solution ? Or does it make no sense to use udp ?
> 
> 
> You might find that some implementations have UDP disabled and it might then make
> it hard to triage what is going on.
> 
> I believe both NetApp's OnTap and Oracle's Solaris have it turned off.

The Linux server allows it, but I've been considering that a
(low-priority) bug, so it wouldn't be safe to assume it will continue
working.

That aside, if you have a perfect network, NFSv4.0 at least will
probably work.  (Not 4.1 since backchannel setup will fail?)

Are you really sure that you can't make tcp scale to thousands of
clients?

--b.

> 
> 
> > 
> > Thanks in advance for your answer.
> > 
> >   Regards
> > 
> >      Philippe
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
