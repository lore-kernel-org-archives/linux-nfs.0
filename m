Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab1GOPRj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 11:17:39 -0400
Date: Fri, 15 Jul 2011 08:17:35 -0700 (PDT)
Message-Id: <20110715.081735.2057304107637222967.davem@davemloft.net>
To: Ian.Campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/10] enable SKB paged fragment lifetime visibility
From: David Miller <davem@davemloft.net>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 15 Jul 2011 12:06:46 +0100

> What is the general feeling regarding this approach?

Not bad, I like that only the users of destructors pay the price of
the extra atomics.

Like you say in patch #8, I wouldn't bother adding a whole new
->sendpage_destructor() OP, just add the new argument to the existing
method.
