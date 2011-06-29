Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37370 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab1F2TRs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 15:17:48 -0400
Date: Wed, 29 Jun 2011 15:17:46 -0400
From: Jim Rees <rees@umich.edu>
To: Tom Haynes <tdh@excfb.com>
Cc: peter.staubach@emc.com, SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Remove warnings on various platforms
Message-ID: <20110629191746.GA8136@merit.edu>
References: <y>
 <1309299723-31539-2-git-send-email-tdh@excfb.com>
 <5E6794FC7B8FCA41A704019BE3C70E8B8285F299@MX31A.corp.emc.com>
 <20110629172858.GA6258@adept.internal.excfb.com>
 <5E6794FC7B8FCA41A704019BE3C70E8B8285F3CB@MX31A.corp.emc.com>
 <20110629183235.GA6422@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110629183235.GA6422@adept.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Tom Haynes wrote:

  On Wed, Jun 29, 2011 at 02:16:24PM -0400, peter.staubach@emc.com wrote:

  > Perhaps we could also consider cleaning up tests.init?  The lists of
    commented out options seems quite unwieldly to me.  Do we really need
    all of that stuff, especially for the much older systems?
  
  Yeah, I've been wondering if modern tools like autoconfig would work
  here. 

I don't know that we need full-blown autoconf, which has portability
problems of its own.  Maybe a shell script or makefile that figures out (or
asks) what you're running on and tweaks tests.init for you.
