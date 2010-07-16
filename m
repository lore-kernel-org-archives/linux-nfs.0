From: Jim Rees <rees@umich.edu>
Subject: Re: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 18:06:09 -0400
Message-ID: <20100716220609.GA7828@merit.edu>
References: <20100716193508.GA14878@merit.edu>
 <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>
 <20100716205355.GA7962@merit.edu>
 <4C40C8DF.8030107@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:50299 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab0GPWGM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 18:06:12 -0400
In-Reply-To: <4C40C8DF.8030107-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  > strlcat and strlcpy should probably go too.
  Anything else?

I don't see any other library functions that should move.  Configure should
check for strlcat and strlcpy, and not compile them if there are system
versions.  Again, I'll do that if no one beats me to it.

On a related note, I've been using benny's pnfs-nfs-utils.git tree as a base
for adding the block layout helper, as suggested by the wiki.  Is that
correct?
