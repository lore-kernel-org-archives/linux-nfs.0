Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([23.128.96.9]:51550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727415AbeJDXg2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2018 19:36:28 -0400
Date: Thu, 04 Oct 2018 09:42:24 -0700 (PDT)
Message-Id: <20181004.094224.1068745934757143781.davem@davemloft.net>
To: dhowells@redhat.com
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH net-next] dns: Allow the dns resolver to retrieve a
 server set
From: David Miller <davem@davemloft.net>
In-Reply-To: <153865967530.25761.13226347009462917363.stgit@warthog.procyon.org.uk>
References: <153865967530.25761.13226347009462917363.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Thu, 04 Oct 2018 14:27:55 +0100

> Allow the DNS resolver to retrieve a set of servers and their associated
> addresses, ports, preference and weight ratings.
 ...
> This can then be used to fetch a whole cell's VL-server configuration for
> AFS, for example.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
