Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:52011 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab2HIR7W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 13:59:22 -0400
Date: Thu, 9 Aug 2012 19:58:28 +0200
From: Zdenek Salvet <salvet@ics.muni.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120809175828.GO604@horn.ics.muni.cz>
Reply-To: salvet@ics.muni.cz
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
 <20120809080642.GE604@horn.ics.muni.cz>
 <20120809144530.GB6592@fieldses.org>
 <1344527573.25447.17.camel@lade.trondhjem.org>
 <20120809165035.GB8230@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120809165035.GB8230@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2012 at 12:50:35PM -0400, J. Bruce Fields wrote:
> > The other source of confusion here, was that the rpc.svcgssd was
> > delivered through a nfs-kernel-server package, which indicates that we
> > first and foremost need to educate the distro packagers.
> 
> Yes, that's a mistake.  The nfs-utils README is where we've been
> documenting daemon startup--I'll work on a patch.  (And see if the man
> pages could use something too.)  And somebody should ping Debian
> (nfs-kernel-server sounds like a Debian thing.)

I sent bug report to Debian Bug Tracking System. Other distributions
may need a notice too, at least SLES<=11.1 and RHEL<=6.3 did not figure 
it out themselves AFAICT ...

Best regards,

Zdenek Salvet                                              salvet@ics.muni.cz 
Institute of Computer Science of Masaryk University, Brno, Czech Republic
and CESNET, z.s.p.o., Prague, Czech Republic
Phone: ++420-549 49 6534                           Fax: ++420-541 212 747
----------------------------------------------------------------------------
      Teamwork is essential -- it allows you to blame someone else.

