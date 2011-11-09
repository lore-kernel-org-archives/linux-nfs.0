Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:20120
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751130Ab1KIGPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2011 01:15:35 -0500
Date: Wed, 9 Nov 2011 07:15:32 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
To: Alexey Dobriyan <adobriyan@gmail.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>, kernel-janitors@vger.kernel.org,
        Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
In-Reply-To: <alpine.DEB.2.02.1111082113380.1880@hadrien>
Message-ID: <alpine.DEB.2.02.1111090710000.1899@hadrien>
References: <1320586010-21931-1-git-send-email-julia@diku.dk> <1320586010-21931-3-git-send-email-julia@diku.dk> <20111108193817.GA3453@p183.telecom.by> <alpine.DEB.2.02.1111082113380.1880@hadrien>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In looking through some examples, I see, e.g.:

 	if (strict_strtoul(buf, 10, &val) < 0)
  		return -EINVAL;
 	if (val < 1 || val > 2)
  		return -EINVAL;

In this case the only valid values are 1 and 2, which are much smaller 
than the u8 range.  Is it useful to use kstrtou8 anyway?  I see that 
kstrtou8 returns -ERANGE not -EINVAL when the value is out of bounds.  If 
kstrtou8 is to be used, should the subsequent if (val < 1 || val > 2) now 
return -ERANGE to be consistent?

julia
