From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 17:02:23 -0400
Message-ID: <4C40C8DF.8030107@RedHat.com>
References: <20100716193508.GA14878@merit.edu> <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil> <20100716205355.GA7962@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
	linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759191Ab0GPVC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 17:02:29 -0400
In-Reply-To: <20100716205355.GA7962-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/16/2010 04:53 PM, Jim Rees wrote:
> David P. Quigley wrote:
> 
>   I agree with this move as I have a label mapping daemon based off of
>   idmapd which uses it as well (although not merged yet). My patch set
>   actually moves this file to support/nfs as well.
> 
> I don't suppose you'd like to isolate just the move and submit that?
I'll take care of it...

> 
> strlcat and strlcpy should probably go too.
Anything else?

steved.
