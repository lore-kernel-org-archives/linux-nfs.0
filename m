From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 14:50:52 -0500
Message-ID: <477E8E1C.9090205@garzik.org>
References: <200801041528.KAA18776@snowhite.cis.uoguelph.ca> <20080104172142.GD17112@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47626 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753354AbYADTvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 14:51:00 -0500
In-Reply-To: <20080104172142.GD17112@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 04, 2008 at 10:28:10AM -0500, Rick Macklem wrote:
>>> Plus, surely in this day and age, we can figure out something better 
>>> than waiting for face-to-face events to test something.  Maybe somebody 
>>> could arrange a donation of some slice of a grid (Amazon EC2?), make 
>>> various OS images available, and give engineers some way to request a 
>>> selection of tests, with a selection of OS images?
>> I tried putting a server up accessible over the internet and only ever
>> got one person testing on it once (or maybe it was just a hacker:-). I
>> did test my client against a server at CITI once, after signing a
>> bakeathon NDA. But, I agree, and I don't really think it even needs
>> a central site. I don't see why vendors couldn't put up servers
>> (production software or whatever they are comfortable having internet
>>  accessible) that clients can test against. I'll be happy to put my
>> server up and I'd be happy to test against internet accessible servers
>> with my client.
> 
> Ditto.  I think it'd be great to have a variety of client and server
> implementations available over the net, but I've had no luck talking
> anybody else into it.

I think blanket public access wouldn't be as effective as passworded 
access to a cluster, much like how people get accounts on kernel.org 
(which is an excellent model for shared-interest services).

On the test cluster, I would want to be able to really stress my 
software, which to any normal firewall or casual observer would look 
like a DoS attempt.

	Jeff



