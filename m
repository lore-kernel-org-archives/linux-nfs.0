Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.cooperix.net ([176.58.120.209]:39403 "EHLO
	relay.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab3KAXnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 19:43:01 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org, Shyam Kaushik <shyamnfs1@gmail.com>
Subject: Re: Need help with NFS Server SUNRPC performance issue
In-reply-to: <20131031151442.GB621@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com> <20131031141538.GA621@fieldses.org> <29447.1383230746@obiwan.sandelman.ca> <20131031151442.GB621@fieldses.org>
Date: Fri, 01 Nov 2013 15:09:03 -0400
Message-ID: <10920.1383332943@sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


J. Bruce Fields <bfields@fieldses.org> wrote:
> > There are some potential instabilities in frequency of IPv6 Router
> > Advertisements due to a bug in the CeroWRT, which initially I was blaming,
> > but I'm no longer convinced, since it happens over IPv4 on the storage VLAN
> > too.
> > 
> > Shyam, please share with me your testing strategy.
> 
> Your problem sounds different; among other things, it's with reads
> rather than writes.

Well.... I sure have problems with writes too.
sshfs is way faster across a LAN, which is just wrong :-)

Michael Richardson
-on the road-


