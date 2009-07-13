From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: Security negotiation
Date: Mon, 13 Jul 2009 11:44:56 -0500
Message-ID: <4A5B6488.2050606@excfb.com>
References: <4A578372.1020005@excfb.com>	 <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com>	 <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>	 <4A57AADE.8080002@excfb.com>	 <2BA1057E-5A8E-4780-B8F2-FCC8BA3846CC@oracle.com>	 <4A57C2F3.4070109@excfb.com>	 <1247265922.8254.30.camel@heimdal.trondhjem.org>	 <4A5B5BCC.5040200@excfb.com> <1247502007.14524.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao102.cox.net ([68.230.240.8]:56973 "EHLO
	eastrmmtao102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597AbZGMQpB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 12:45:01 -0400
In-Reply-To: <1247502007.14524.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> Well, how does the security negotiating NFSv3 client discover that?
> I'm assuming that in the case of NFSv4, you would return
> NFS4ERR_WRONGSEC if the user attempts to write to the server, but what
> do you do in the case of NFSv3? Do you return an rpc level AUTH_TOOWEAK
> error instead?
>
>     Trond
>   


Yes, that is what we would do in this case.


