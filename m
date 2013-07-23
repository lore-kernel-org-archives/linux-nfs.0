Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:42865 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933577Ab3GWSc4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 14:32:56 -0400
Date: Tue, 23 Jul 2013 21:32:51 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4: Fix a regression against the FreeBSD server
Message-ID: <20130723183250.GR5636@mwanda>
References: <20130723160627.GA2370@elgon.mountain>
 <1374595949.10794.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1374595949.10794.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 23, 2013 at 04:12:28PM +0000, Myklebust, Trond wrote:
> 
> Hi Dan,
> 
> Maybe I need another coffee, but right now I don't see what the problem
> is. We only set FATTR4_WORD2_SECURITY_LABEL if the check that label !=
> NULL passes. What am I missing?
> 

Ah.  You are right.  Sorry for the noise.  Don't drink the extra
coffee, you're at the correct level now, and drinking more will just
give you jitters.

regards,
dan carpenter
