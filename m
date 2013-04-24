Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45039 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893Ab3DXOBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 10:01:53 -0400
Date: Wed, 24 Apr 2013 10:01:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Malte =?utf-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
Message-ID: <20130424140152.GA9794@fieldses.org>
References: <5176E715.2070201@gmx.de>
 <20130423215807.GL3676@fieldses.org>
 <51777494.8010306@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51777494.8010306@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 07:58:44AM +0200, Malte Schröder wrote:
> On 23.04.2013 23:58, J. Bruce Fields wrote:
> > On Tue, Apr 23, 2013 at 09:55:01PM +0200, Malte Schröder wrote:
> >> Hi,
> >> when I update my server from kernel 3.8.5 to 3.9-rc8 I cannot mount its
> >> NFS exports from clients using nfs4 and sec=krb5. Using sec=sys works,
> >> using 3.8.5 also works good with both modes.
> > 
> > Could you get a network trace showing the failure
> > 
> > Run
> > 
> > 	tcpdump -s0 -wtmp.pcap
> > 
> > then send us tmp.pcap.
> > 
> > (You can also take a look at tmp.pcap yourself in wireshark--it may be
> > obvious where the failure occurs.)
> > 
> > --b.
> > 
> 
> The trace is attached. It contains two tries, the first using sec=sys,
> the second sec=krb5. I used "mount -tnfs -overs=4,sec=krb5 gateway:/
> /mnt". NFS-Utils have version 1.2.6.

Looks like the context creation succeeds and then the first use of the
new context (a PUTROOTFH+GETATTR) never gets a response.

Nothing interesting in the server's logs?

--b.
