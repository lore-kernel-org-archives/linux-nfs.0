Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab3KDXDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 18:03:17 -0500
Date: Mon, 4 Nov 2013 18:03:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Richardson <mcr@sandelman.ca>
Cc: linux-nfs@vger.kernel.org, Shyam Kaushik <shyamnfs1@gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131104230316.GE8828@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
 <20131031141538.GA621@fieldses.org>
 <29447.1383230746@obiwan.sandelman.ca>
 <20131031151442.GB621@fieldses.org>
 <10920.1383332943@sandelman.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <10920.1383332943@sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 01, 2013 at 03:09:03PM -0400, Michael Richardson wrote:
> 
> J. Bruce Fields <bfields@fieldses.org> wrote:
> > > There are some potential instabilities in frequency of IPv6 Router
> > > Advertisements due to a bug in the CeroWRT, which initially I was blaming,
> > > but I'm no longer convinced, since it happens over IPv4 on the storage VLAN
> > > too.
> > > 
> > > Shyam, please share with me your testing strategy.
> > 
> > Your problem sounds different; among other things, it's with reads
> > rather than writes.
> 
> Well.... I sure have problems with writes too.
> sshfs is way faster across a LAN, which is just wrong :-)

That sounds suspect, yes, but we'd need some more details (exactly
what's your test, and what results do you get?).

--b.
