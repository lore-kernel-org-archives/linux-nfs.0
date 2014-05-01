Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37436 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbaEAT7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2014 15:59:47 -0400
Date: Thu, 1 May 2014 15:59:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <mlord@pobox.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140501195944.GA14625@fieldses.org>
References: <533D8D73.1090603@pobox.com>
 <20140403171643.GB28790@pad.redhat.com>
 <533D9F8A.6030001@pobox.com>
 <20140403145504.3b04170e@tlielax.poochiereds.net>
 <20140403201627.GC8343@fieldses.org>
 <20140403192146.79679909@tlielax.poochiereds.net>
 <20140404135842.GB17594@fieldses.org>
 <5362350A.6040402@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5362350A.6040402@pobox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2014 at 07:50:34AM -0400, Mark Lord wrote:
> Still a regression in 3.14.2 now.
> Anyone got plans to push this patch out to mainline, as well as +stable ?

This is upstream as 082f31a2169bd639785e45bf252f3d5bce0303c6 "nfsd:
revert v2 half of "nfsd: don't return high mode bits"", with a cc to
stable@kernel.org, so I assume it's just taking a little time for stable
to pick it up.

--b.
