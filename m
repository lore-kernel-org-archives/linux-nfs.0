From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [patch] sunrpc: handle allocation errors from
 __rpc_lookup_create()
Date: Sun, 21 Mar 2010 12:27:02 -0400
Message-ID: <1269188822.3215.2.camel@localhost.localdomain>
References: <20100321092818.GI5331@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33873 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636Ab0CUQ1g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 12:27:36 -0400
In-Reply-To: <20100321092818.GI5331@bicker>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-03-21 at 12:28 +0300, Dan Carpenter wrote: 
> __rpc_lookup_create() can return ERR_PTR(-ENOMEM).
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Well spotted. Applied!

Cheers
  Trond
