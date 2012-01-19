Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46218 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757027Ab2ASRKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 12:10:37 -0500
Message-ID: <4F184E70.5070902@parallels.com>
Date: Thu, 19 Jan 2012 21:10:08 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 4/5] SUNRPC: ip map cache per network namespace cleanup
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <20120119144931.9957.78601.stgit@localhost6.localdomain6> <20120119163722.GE527@fieldses.org>
In-Reply-To: <20120119163722.GE527@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.01.2012 20:37, J. Bruce Fields пишет:
> On Thu, Jan 19, 2012 at 06:49:31PM +0400, Stanislav Kinsbursky wrote:
>> This patch converts ip_map_cache per network namespace implemenetation to the
>> same view, as other caches done in the series.
>> Besides generalization, code becomes shorter with this patch.
>
> Again, isnt' it ip_map_cache, and not one of the dynamically created
> cache details, that's being passed to the lookup routines?
>
> I may just be confused....
>

Nope. ip_map_cache was made per network namespace a long time ago.
But it was done in other way: no static templates - just allocation and 
initialization.
But static template looks clearer to me. So I've used this approach for other 
caches. And decided to update ip_map_cache management in the same way.

-- 
Best regards,
Stanislav Kinsbursky
