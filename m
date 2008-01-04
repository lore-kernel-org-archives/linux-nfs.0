From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 13:21:13 -0500
Message-ID: <20080104182113.GI17112@fieldses.org>
References: <200801041528.KAA18776@snowhite.cis.uoguelph.ca> <20080104172142.GD17112@fieldses.org> <477E750A.2030905@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbYADSVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 13:21:17 -0500
In-Reply-To: <477E750A.2030905-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2008 at 12:03:54PM -0600, Tom Haynes wrote:
> I suspect that the explosion of virtual servers has
> probably killed this type of effort. It appears much
> easier for me to give you an image than to expose
> a machine on the network.

Each little bit you can take away from the overhead will make people
much more likely to test.  The connectathon experience is just:

	- Look up server's name.
	- mount servername:/ /mnt/
	- run test

The virtual server image approach requires at least getting the server
image and probably doing some configuration too, and then remembering to
get updates occasionally.

> Sun actually has a set of test machines the public can
> use to regression test OpenSolaris fixes. I'm not sure
> if it can accommodate foreign OSes just yet.
>
> And to add to Rick's story, we've got the pNFS enabled
> bits available for download. We've only gotten feedback
> from one person. So either our code is really great and
> we are not getting feedback, or people are just waiting
> for the pNFS implementations to mature.

Or it got released just before the holidays....

>
> We did get a request to make the bits available as a
> VMware image. :->

Hah.

--b.
