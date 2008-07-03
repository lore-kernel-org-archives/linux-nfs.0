From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: Massive NFS problems on large cluster with large number of	mounts
Date: Thu, 03 Jul 2008 07:31:23 +0200
Message-ID: <486C642B.3020100@aei.mpg.de>
References: <4869E8AB.4060905@aei.mpg.de>	 <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de>	 <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:41651 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800AbYGCFb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2008 01:31:29 -0400
In-Reply-To: <1215032676.7087.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:

> 
> Alternatively, just change the values of /proc/sys/sunrpc/min_resvport
> and /proc/sys/sunrpc/max_resvport to whatever range of ports you
> actually want to use.

That looks indeed great. We will test this hopefully today and see where
the next ceiling is, we will bang our heads into ;)

Thanks

Carsten
