From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils atomicio.c
Date: Mon, 19 Jul 2010 11:33:08 -0400
Message-ID: <4C447034.4020006@RedHat.com>
References: <20100716193508.GA14878@merit.edu>	 <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>	 <20100716205355.GA7962@merit.edu> <4C40C8DF.8030107@RedHat.com>	 <20100716220609.GA7828@merit.edu> <1279319622.8180.2.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936222Ab0GSPdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 11:33:13 -0400
In-Reply-To: <1279319622.8180.2.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/16/2010 06:33 PM, David P. Quigley wrote:
> On Fri, 2010-07-16 at 18:06 -0400, Jim Rees wrote:
>> Steve Dickson wrote:
>>
>>   > strlcat and strlcpy should probably go too.
>>   Anything else?
>>
>> I don't see any other library functions that should move.  Configure should
>> check for strlcat and strlcpy, and not compile them if there are system
>> versions.  Again, I'll do that if no one beats me to it.
>>
>> On a related note, I've been using benny's pnfs-nfs-utils.git tree as a base
>> for adding the block layout helper, as suggested by the wiki.  Is that
>> correct?
> 
> Just got back from dinner and I'm heading out soon for the weekend but
> here is the patch that I have. It should apply on top of
> 2ef57222b10a91f4b96a06808d05a47e8f4c14f7 and moves strlcat and strlcpy
> as well. The only think you might have to check is I know at some point
> some changes were made to cfg.c and cfg.h make sure the ones I have in
> this patch are the new ones instead of the old ones. I'd take a closer
> look but I'm short on time here.
> 
>
Question: Is there a reason need a private version of queue.h, instead
of using the one ins /usr/include/sys?

steved.

