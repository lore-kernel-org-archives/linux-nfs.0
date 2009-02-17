From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 18 Feb 2009 08:37:00 +1030
Message-ID: <1234908420.14585.40.camel@sibyl.beware.dropbear.id.au>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <1233699391.7161.11.camel@heimdal.trondhjem.org>
	 <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com>
	 <1233771633.7161.35.camel@heimdal.trondhjem.org>
	 <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
	 <1233773231.7161.51.camel@heimdal.trondhjem.org>
	 <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au>
	 <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com>
	 <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au>
	 <985DCB56-4365-40FC-B48D-43C28742908F@oracle.com>
	 <1234402083.13862.273.camel@sibyl.beware.dropbear.id.au>
	 <C7FF32B1-AF6D-470B-96DB-4BD77E90C50C@oracle.com>
	 <1234711952.25265.34.camel@sibyl.beware.dropbear.id.au>
	 <5E2B57AC-1977-449B-B595-354717A6ECD3@oracle.com>
	 <1234872202.14585.33.camel@sibyl.bewa! re.dropbear.id.au>
	 <30C44273-7011-46AD-B79B-FCD06E9F25FE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:52247 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbZBQWHT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 17:07:19 -0500
In-Reply-To: <30C44273-7011-46AD-B79B-FCD06E9F25FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2009-02-17 at 12:29 -0500, Chuck Lever wrote:

> I think the correct way to proceed here is to address the original  
> problem without adding the scope ID check, then explore the scope ID  
> issue separately.  The presenting problem in 11061 affects IPv4  
> addresses too if I'm not mistaken, and IPv4 is fairly widely deployed,  
> so it needs to be fixed now.
Absolutely. Where it bit me, and as far as I know all the the respondents, was with IPv4 networks.

> If scope ID matching is a problem in nfs_match_client, then it is also  
> an issue for other places in the NFS client, and should be fixed in  
> all those places at once, in a single patch that documents the scope  
> ID matching requirement.

Sounds reasonable. I'll change the comment somehow to indicate why the
scope_id field is not being compared.

Regards,

Ian

-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

