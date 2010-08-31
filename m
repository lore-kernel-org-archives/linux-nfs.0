Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60178 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534Ab0HaVuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 17:50:24 -0400
Date: Tue, 31 Aug 2010 17:50:22 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org
Subject: Re: Linux pNFS status meeting 08/26
Message-ID: <20100831215022.GA27102@infradead.org>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>
 <OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com>
 <OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
 <4C761A61.2070203@panasas.com>
 <273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
 <20100831162648.GF3071@fieldses.org>
 <AANLkTi=85p8qm-_RKRH60CZBJPMp5g_Qj2NHvHcDaw1S@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=85p8qm-_RKRH60CZBJPMp5g_Qj2NHvHcDaw1S@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 31, 2010 at 10:51:11AM -0700, Fred Isaman wrote:
> Note that the not much touches the common code, especially in our
> first submission, so it will be a fairly small patch, which we will
> not be adverse to breaking up at reviewers request.  Right now we are
> trying to accommodate Cristoph's request for larger patches combined
> with Trond's request for small, easy to review patches for anything
> that touches common code.

I'm not Cristoph, but for changes to generic code anywhere in the kernel
small patches are indeed a requirement, adn they should do exactly one
thing.  Adding new code is a different issue from that.

