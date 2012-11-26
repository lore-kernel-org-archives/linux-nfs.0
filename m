Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31734 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647Ab2KZQja convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 11:39:30 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "dE ." <de.techno@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Slow NFS loop performance.
Date: Mon, 26 Nov 2012 16:39:27 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90930BCC7@SACEXCMBX04-PRD.hq.netapp.com>
References: <50AF57A3.3090000@gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092F876C@SACEXCMBX04-PRD.hq.netapp.com>
 <50B39233.3070406@gmail.com>
In-Reply-To: <50B39233.3070406@gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of dE .
> Sent: Monday, November 26, 2012 11:01 AM
> To: linux-nfs@vger.kernel.org
> Subject: Re: Slow NFS loop performance.
> 
> On 11/24/12 00:34, Myklebust, Trond wrote:
> > You're using a non-default timeo=60 on a TCP connection.
> >
> > Why?
> 
> This's a LAN with just 2 PCs. So there're no packet drops, so there's no point
> resending requests frequently.

The default is timeo=600.

Timeo=60 is a 6 second timeout, and is not only pointless for a TCP connection, it can actually cause unnecessary disruptions when you use NFSv4 because all retransmissions are required to do a TCP disconnect+reconnect cycle.

Trond
