Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35013 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887Ab2FKNoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 09:44:37 -0400
Message-ID: <4FD5F629.1070508@panasas.com>
Date: Mon, 11 Jun 2012 16:44:09 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, bfields <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <4FD5F35A.3000903@panasas.com>
In-Reply-To: <4FD5F35A.3000903@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/11/2012 04:32 PM, Boaz Harrosh wrote:

> On 06/11/2012 03:39 PM, Jeff Layton wrote:
> 
>>>
>>> But I'm guessing we were wrong to assume that existing setups that
>>> people perceived as working would have that path, because the failures
>>> in the absence of that path were probably less obvious.
>>>


One more thing, the most important one. We have already fixed that in the
past and I was hoping the lesson was learned. Apparently it was not, and
we are doomed to do this mistake for ever!!

What ever crap fails times out and crashes, in the recovery code, we don't
give a dam. It should never affect any Server-client communication.

When the grace periods ends the clients gates opens period. *Any* error
return from state recovery code must be carefully ignored and normal
operations resumed. At most on error, we move into a mode where any
recovery request from client is accepted, since we don't have any better
data to verify it.

Please comb recovery code to make sure any catastrophe is safely ignored.
We already did that before and it used to work.

>>> --b.


Thanks
Boaz

