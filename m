From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Mon, 18 Aug 2008 18:39:53 -0400
Message-ID: <20080818223953.GB32543@fieldses.org>
References: <48A30685.6050301@opengridcomputing.com> <20080813211953.GN26765@fieldses.org> <48A36004.1030304@opengridcomputing.com> <20080814194847.GH23859@fieldses.org> <48A4A23D.8040702@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbYHRWkF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2008 18:40:05 -0400
In-Reply-To: <48A4A23D.8040702@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2008 at 04:23:09PM -0500, Tom Tucker wrote:
> Here are the relevant specs:
>
> Unfortunately, the IB specs are private to the IBTA.
> http://www.infinibandta.org/home
>
> The OFA verbs most closely resemble IB verbs.
>
> Here are the iWARP protocol specs:
>
> http://www.ietf.org/rfc/rfc5040.txt
> http://www.ietf.org/rfc/rfc5041.txt
> http://www.ietf.org/rfc/rfc5044.txt
>
> Here are the iWARP verbs specs. This is what the adapters where written to.
>
> http://www.rdmaconsortium.org/home/RNIC_Verbs_Overview2.pdf
> http://www.rdmaconsortium.org/home/draft-hilland-iwarp-verbs-v1.0-RDMAC.pdf

OK, thanks very much to you and James for all the explanation.  And
actually the IB specs do appear to be available if you give them your
name and address?

So could one of you add some of this (the explanation of the security
issues, at least) to Documentation/filesystems/nfs-rdma.txt?

I'm worried about the fact that the amount of trust required in the
network will vary so much depending on exactly which hardware and kernel
version the user has.

As long as this is relatively specialized hardware, perhaps it's not
such a big deal....  But at the very least I think we should make sure
this is carefully documented.

--b.
