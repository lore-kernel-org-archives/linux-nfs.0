From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP
	snd/rcv buffer values
Date: Mon, 16 Jun 2008 13:59:46 -0400
Message-ID: <20080616175946.GB27083@fieldses.org>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <20080613205339.GM8501@fieldses.org> <4853098C.8070200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589AbYFPR75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 13:59:57 -0400
In-Reply-To: <4853098C.8070200@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 04:58:04PM -0700, Dean Hildebrand wrote:
> The reason it is an art is that you don't know the hardware that exists  
> between the client and server.  Talking about things like BDP is fine,  
> but in reality there are limited buffer sizes, flaky hardware,  
> fluctuations in traffic, etc etc.  Using the BDP as a starting point  
> though seems like the best solution, but since the linux server doesn't  
> know anything about what the BDP is, it is tough to hard code any value  
> into the linux kernel.  As you said, if we just give a reasonable  
> default value and then ensure people can play with the knobs.  Most  
> people use NFS within a LAN, and to date there has been little if any  
> discussion on using NFS over the WAN (hence my interest), so I would  
> argue that the current values might not be all that bad with regards to  
> defaults (at least we know the behaviour isn't horrible for most people).
>
> Networks are messy.  Anyone who wants to work in the WAN is going to  
> have to read about such things, no way around it.  A simple google  
> search for 'tcp wan' or 'tcp wan linux' gives loads of suggestions on  
> how to configure your network, so it really isn't a burden on sysadmins  
> to do such a search and then use the given knobs to adjust the tcp  
> buffer size appropriately.  My patch gives sysadmins the ability to do  
> the google search and then have some knobs to turn.
>
> Some sample tcp tuning guides that I like:
> http://acs.lbl.gov/TCP-tuning/tcp-wan-perf.pdf
> http://acs.lbl.gov/TCP-tuning/linux.html
> http://gentoo-wiki.com/HOWTO_TCP_Tuning (especially relevant is the part  
> about the receive buffer)
 
> http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Hildebrand_98265.pdf 
> (our initial paper on pNFS tuning)

Several of those refer to problems that can happen when the receive
buffer size is set unusually high, but none of them give a really
detailed description of the behavior in that case--do you know of any?

--b.
