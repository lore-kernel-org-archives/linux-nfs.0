Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41706 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbHYGDx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 02:03:53 -0400
Date: Tue, 25 Aug 2015 09:03:45 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: knfsd: clean up nfsd filesystem interfaces
Message-ID: <20150825060345.GV5610@mwanda>
References: <20150822195814.GA20768@mwanda>
 <20150822185618.41d20096@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150822185618.41d20096@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 22, 2015 at 06:56:18PM -0400, Jeff Layton wrote:
> I think we need to keep that check there (or something like it), even if
> just to future-proof this code. But, I am open to suggestions on ways to
> make the static checker happy.
> 

Eventually (and not too far into the future actually) I will fix Smatch
so that it knows that the callers never use size more than
SIMPLE_TRANSACTION_LIMIT so it won't print this error.

So I guess we can keep the check.

regards,
dan carpenter

