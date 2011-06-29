Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepo103.cox.net ([68.230.241.215]:46261 "EHLO
	eastrmfepo103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab1F2R2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 13:28:43 -0400
Date: Wed, 29 Jun 2011 12:28:58 -0500
From: Tom Haynes <tdh@excfb.com>
To: peter.staubach@emc.com
Cc: tdh@excfb.com, SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Remove warnings on various platforms
Message-ID: <20110629172858.GA6258@adept.internal.excfb.com>
References: <y>
 <1309299723-31539-2-git-send-email-tdh@excfb.com>
 <5E6794FC7B8FCA41A704019BE3C70E8B8285F299@MX31A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B8285F299@MX31A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 29, 2011 at 07:53:19AM -0400, peter.staubach@emc.com wrote:
> Hi.
> 
> For some of these new casts, wouldn't be it better to simply declare the variable to be the correct type to start with instead of casting some other type?  For example, the socklen_t variables?
> 
> It seems funny that all of those XDR routines need to be casted as well.
> 
> 	Thanx...
> 
> 		ps

I tried to go with the most innocent changes I could. My main concern
is lack of access to different platforms to do sanity compiles
and unit testing.

-- 
Tom Haynes
ex-cfb
