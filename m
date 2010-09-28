From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
Date: Tue, 28 Sep 2010 18:23:23 +0400
Message-ID: <4CA1FA5B.1080002@parallels.com>
References: <4CA06C7A.5060307@parallels.com>	 <4CA06CA0.6060606@parallels.com>	 <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>	 <4CA1C71D.70109@parallels.com> <1285682384.9185.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6598 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716Ab0I1OX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 10:23:57 -0400
In-Reply-To: <1285682384.9185.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> If you are redoing the patch, then could you please just get rid of the
> above forward declaration for xs_free_xprt, and instead just move the
> function itself further up the file?

Sure. Will do it soon.

> Cheers
>   Trond
