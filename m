Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932579AbbGJVVw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 17:21:52 -0400
Date: Fri, 10 Jul 2015 17:21:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        william@gandi.net
Subject: Re: [RFC PATCH 0/4] locks/nfs: fix use-after-free problem in unlock
 codepath
Message-ID: <20150710212151.GC7665@fieldses.org>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
 <20150710211054.GB7665@fieldses.org>
 <20150710171426.082be2b0@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150710171426.082be2b0@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 05:14:26PM -0400, Jeff Layton wrote:
> Thanks for testing, Bruce. Yeah at the very least we should get the
> first one in ASAP. The rest can probably wait for more thorough review.
> There is a real bug there, but I don't think people are hitting it
> regularly.

OK.  Free feel to add my tested-by: and/or reviewed-by: for those, they
are passing my tests and the patches look right to me....

--b.
