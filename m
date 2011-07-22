Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab1GVONv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 10:13:51 -0400
Date: Fri, 22 Jul 2011 07:13:49 -0700 (PDT)
Message-Id: <20110722.071349.1486529438674839197.davem@davemloft.net>
To: Ian.Campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC v2 0/13] enable SKB paged fragment lifetime
 visibility
From: David Miller <davem@davemloft.net>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Well, Ian, because you put all of these "struct page *" MM layer
const changes in here I can't just apply this series once you
get it ready enough from a networking perspective.

Why not do the const crap later, so it can be done independently
of these changes and not be a dependency upon them?

I know you want to pass const page structs down as far as possible,
but that can wait for later, make the networking bits work on
non-const pointers for now.
