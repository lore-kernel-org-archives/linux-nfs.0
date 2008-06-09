From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --  
  how best to	close the sockets?
Date: Mon, 09 Jun 2008 12:40:05 -0400
Message-ID: <RTPCLUEXC1-PRDusMjQ000001d5@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
 <484D4659.9000105@redhat.com>
 <20080609111821.6e06d4f8@tleilax.poochiereds.net>
 <RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
 <20080609120110.1fee7221@tleilax.poochiereds.net>
 <RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
 <20080609122249.51767b21@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org,
	lhh@redhat.com, nfsv4@linux-nfs.org, nhorman@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26706 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbYFIQkX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 12:40:23 -0400
In-Reply-To: <20080609122249.51767b21-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
References: <20080609103137.2474aabd-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
 <484D4659.9000105@redhat.com>
 <20080609111821.6e06d4f8-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
 <RTPCLUEXC1-PRDOLZCH000001d2-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <20080609120110.1fee7221-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
 <RTPCLUEXC1-PRDF8Eqf000001d4-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <20080609122249.51767b21-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 12:22 PM 6/9/2008, Jeff Layton wrote:
>That might be worth investigating, but sounds like it might cause problems
>with the services associated with IP addresses that are staying on the
>victim server.

Jeff, I think you have many years of job security to look forward to, here. :-)

Since you sent this to the NFSv4 list - is there any chance you're thinking
to not transparently take over IP addresses, but use NFSv4 locations and
referrals for these "migrations"? Yes, I know some clients may not quite be
there yet.

Tom.

