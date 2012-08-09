Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:49859 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755366Ab2HIIG5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 04:06:57 -0400
Date: Thu, 9 Aug 2012 10:06:42 +0200
From: Zdenek Salvet <salvet@ics.muni.cz>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120809080642.GE604@horn.ics.muni.cz>
Reply-To: salvet@ics.muni.cz
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1344431887.3423.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 08, 2012 at 01:18:09PM +0000, Myklebust, Trond wrote:
> > We don't see any hard failures because NFS protocol does
> > not depend on working callback RPCs, but no delegations are granted
> > (we had nfs-kernel-server package installed on clients before which masked
> > the bug).
> 
> So your gripe that you object to us requiring you to run rpc.svcgssd in
> order to obtain server features such as NFSv4 callbacks?

Absolutely not! Just thinking why we did not notice the problem earlier ...

-- 
Zdenek Salvet                                              salvet@ics.muni.cz 
Institute of Computer Science of Masaryk University, Brno, Czech Republic
and CESNET, z.s.p.o., Prague, Czech Republic
Phone: ++420-549 49 6534                           Fax: ++420-541 212 747
----------------------------------------------------------------------------
      Teamwork is essential -- it allows you to blame someone else.

