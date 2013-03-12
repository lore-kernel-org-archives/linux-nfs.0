Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:4013 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591Ab3CLCxa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 22:53:30 -0400
Message-ID: <513E989E.8060206@canonical.com>
Date: Mon, 11 Mar 2013 20:53:18 -0600
From: Tim Gardner <tim.gardner@canonical.com>
MIME-Version: 1.0
To: Tom Tucker <tom@opengridcomputing.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH linux-next v3] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
References: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com> <1363036508-24935-1-git-send-email-tim.gardner@canonical.com> <20130311212535.GG642@fieldses.org> <513E6271.3060107@opengridcomputing.com>
In-Reply-To: <513E6271.3060107@opengridcomputing.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/11/2013 05:02 PM, Tom Tucker wrote:
> On 3/11/13 4:25 PM, J. Bruce Fields wrote:

<snip>

>> Looks good to me; wish we could get it tested....
>
> I will test it. Tim could you please send me a final version that you'd
> like tested as a single message?
>

I'm a little confused about what you are asking. I think v3 of the patch 
is the final version (unless you find bugs with it).

> Would someone (like Tim maybe ... hint hint) look at tearing out all
> those dead registration strategies? I don't think we need or will ever
> use bounce-buffers, memory windows, or mlnx fmr.  The only two that are
> used and tested are all-phys and FRMR (the default).
>

Dunno if I'll get time for that. I had a one day window where I could 
hack out some simple patches. Now I'm back to the usual grindstone.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
