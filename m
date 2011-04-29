Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:49621 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873Ab1D2RGC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 13:06:02 -0400
Date: Fri, 29 Apr 2011 13:05:54 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David McGiven <davidmcgivenn@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Linux to Netapp -> Is UDP over WAN safe as long as I use
 "sync, hard and intr" ?
Message-ID: <20110429170554.GA10047@merit.edu>
References: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com>
 <20AFBC51-7103-47E9-825A-A52B4FCA08B6@oracle.com>
 <6FF9D79F-27E7-49E5-AE4D-A5A17C8F1403@gmail.com>
 <1304096044.3654.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1304096044.3654.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  Have you checked the autonegotiation settings on your NIC? 'ethtool
  eth0' is your friend...

I bet it's an mtu problem.  The PIX is some kind of vpn tunnel thing that
probably truncates packets, and if it's been mis-installed it may be
blocking the icmp replies needed for path mtu discovery.
