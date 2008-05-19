From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] svcrdma: Limit ORD based on client's advertised IRD
Date: Mon, 19 May 2008 14:34:36 -0400
Message-ID: <RTPCLUEXC1-PRD4mG0E00000117@RTPMVEXC1-PRD.hq.netapp.com>
References: <1211214842.31725.38.camel@trinity.ogc.int>
 <RTPCLUEXC1-PRD1q4gt00000114@RTPMVEXC1-PRD.hq.netapp.com>
 <1211221933.31725.56.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Bruce Fields <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4601 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbYESSgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 14:36:22 -0400
In-Reply-To: <1211221933.31725.56.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
References: <1211214842.31725.38.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
 <RTPCLUEXC1-PRD1q4gt00000114-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <1211221933.31725.56.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:32 PM 5/19/2008, Tom Tucker wrote:
>> Well, technically the iWARP connection manager *currently* does not
>> exchange these values. I think the comment would be more accurate
>> if it said "in the absence of"...
>
>I'm not sure it really has anything to do with where it is implemented.

That wasn't my point - I meant, in the absence of information what the
peer's maximum might be, the server has to make something up. But, future
iwarp cm's could pass it.

What value bubbles up in this field from current iWARP connections? Is
it total garbage, or at least, recognizably useless (-1)?

>> >-static void handle_connect_req(struct rdma_cm_id *new_cma_id)
>> >+static void handle_connect_req(struct rdma_cm_id *new_cma_id, u8 
>client_ird)
>> 
>> While "u8" might be the limit of the implementations today, wouldn't "int" be
>> easier to understand, and more portable?
>> 
>
>I think that 'int' might provoke the "wrath of Chuck". Unsigned
>something else --

Okay, well if not "int", then at least some type which is not a specific
storage size. u{8,16,32} etc should be reserved for describing hardware
and on-wire stuff, and handled as native when used locally.

Tom.

