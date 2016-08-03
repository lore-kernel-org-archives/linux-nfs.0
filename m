Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758235AbcHCTeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 15:34:07 -0400
Date: Wed, 3 Aug 2016 15:34:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Problem re-establishing GSS contexts after a server reboot
Message-ID: <20160803193405.GA5901@fieldses.org>
References: <CAN-5tyHWPvNeq-0kNErTY+nENqkfrbGXwutcMgaOYcvYL3fX7Q@mail.gmail.com>
 <42FD3D54-79F9-485A-A2B4-FBFA65C2FC16@oracle.com>
 <CAN-5tyGJ8YUesk-KBTK+DFqaRV9wNvjQp-4EkcoU4J58EmM7_A@mail.gmail.com>
 <CAN-5tyEyg4aYXc5Zr-diLHxhkU1VnvYaaKS01qCH-vtxa8qzqg@mail.gmail.com>
 <CC879117-DCA5-4BC1-8A70-FA859546CD01@oracle.com>
 <CAN-5tyGnK7Zus2pBg5dO__XZ8NrM_h9k4EXzJERneHBBnn6VPg@mail.gmail.com>
 <CAN-5tyGJQXrLm7L98UgJULT=gQjsuVM86KGwEkGPuS8GBTAGrA@mail.gmail.com>
 <9E866C53-DD4B-419E-ABF0-64B04609C066@oracle.com>
 <20160802180642.GA15324@fieldses.org>
 <4A1D033F-7611-401D-A9DF-E5806EFF921C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4A1D033F-7611-401D-A9DF-E5806EFF921C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 03, 2016 at 03:14:21PM -0400, Chuck Lever wrote:
> 
> On Aug 2, 2016, at 2:06 PM, bfields@fieldses.org wrote:
> > You should be able to use the same context with different services.
> > 
> > Apologies, I haven't caught up with the whole discussion above, this one
> > point just jumped out at me.  If you're trying to request a whole new
> > gss context just so you can use, e.g., integrity instead of privacy,
> > then something's wrong.
> 
> As I understand it, GSS contexts are fungible until they have been
> used. On first use, the context is bound to a particular service.
> Subsequently it cannot be used with another service.
> 
> The Solaris server seems to expect that separate GSS contexts are
> needed when the same UID employs different GSS services. If Solaris
> is wrong about this, can you show me RFC language that specifically
> allows it? I can take that back to the Solaris developers.

No, you're right, apologies; from https://tools.ietf.org/html/rfc2203

	Although clients can change the security service and QOP used on
	a per-request basis, this may not be acceptable to all RPC
	services; some RPC services may "lock" the data exchange phase
	into using the QOP and service used on the first data exchange
	message.

--b.
