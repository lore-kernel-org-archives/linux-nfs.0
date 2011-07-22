Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:64450 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201Ab1GVNIQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 09:08:16 -0400
Subject: [PATCH/RFC v2 0/13] enable SKB paged fragment lifetime visibility
From: Ian Campbell <Ian.Campbell@citrix.com>
To: <netdev@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jul 2011 14:08:15 +0100
Message-ID: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

This is v2 of my series to enable visibility into SKB paged fragment's
lifecycles, v1 is at [0] and contains some more background and rationale
but basically the series allows entities which inject pages into the
networking stack to receive a notification when the stack has really
finished with those pages (i.e. including retransmissions, clones,
pull-ups etc) and not just when the original skb is finished with, which
is beneficial to many subsystems which wish to inject pages into the
network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

I have updated based on the feedback from last time. In particular:
      * Added destructor directly to sendpage() protocol hooks instead
        of inventing sendpage_destructor() (David Miller)
      * Dropped skb_frag_pci_map in favour of skb_frag_dma_map on Michał
        Mirosław's advice
      * Pushed the NFS fix down into the RPC layer. (Trond)

I also split out the patches to make protocols use the new interface
into per-protocol patches. I held back on splitting up the patch to
drivers/* (since that will cause an explosion in the series length) --
I'll do this split for v3.

FYI I'm travelling for the next two weeks, although I expect to have
good access to mail next week I'm less sure about the following week.

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2

