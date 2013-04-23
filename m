Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932581Ab3DWV6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 17:58:07 -0400
Date: Tue, 23 Apr 2013 17:58:07 -0400
To: Malte =?utf-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
Message-ID: <20130423215807.GL3676@fieldses.org>
References: <5176E715.2070201@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5176E715.2070201@gmx.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 23, 2013 at 09:55:01PM +0200, Malte Schröder wrote:
> Hi,
> when I update my server from kernel 3.8.5 to 3.9-rc8 I cannot mount its
> NFS exports from clients using nfs4 and sec=krb5. Using sec=sys works,
> using 3.8.5 also works good with both modes.

Could you get a network trace showing the failure

Run

	tcpdump -s0 -wtmp.pcap

then send us tmp.pcap.

(You can also take a look at tmp.pcap yourself in wireshark--it may be
obvious where the failure occurs.)

--b.
