From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 19:43:57 -0500
Message-ID: <477ED2CD.9010200@garzik.org>
References: <200801041528.KAA18776@snowhite.cis.uoguelph.ca> <20080104172142.GD17112@fieldses.org> <477E8E1C.9090205@garzik.org> <Pine.LNX.4.64.0801042055490.18738@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36483 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbYAEAoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 19:44:00 -0500
In-Reply-To: <Pine.LNX.4.64.0801042055490.18738-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter =C5strand wrote:
> On Fri, 4 Jan 2008, Jeff Garzik wrote:
>=20
>>> Ditto.  I think it'd be great to have a variety of client and serve=
r
>>> implementations available over the net, but I've had no luck talkin=
g
>>> anybody else into it.
>> I think blanket public access wouldn't be as effective as passworded=
 access to
>> a cluster, much like how people get accounts on kernel.org (which is=
 an
>> excellent model for shared-interest services).
>>
>> On the test cluster, I would want to be able to really stress my sof=
tware,
>> which to any normal firewall or casual observer would look like a Do=
S attempt.
>=20
> I'm not afraid of stress-tests that looks like DoS attempts. What wor=
ries=20
> me is that a writable export will be used for sharing warez or someth=
ing=20
> like that.=20

I would think that LAN testing would have more value than WAN testing=20
anyway.  So just close off the firewall, except for ssh bastion host or=
=20
similar.

	Jeff




