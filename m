From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 07 Jul 2008 16:51:17 -0400
Message-ID: <1215463877.19512.40.camel@localhost>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
	 <20080703204543.GI30918@fieldses.org> <1215454820.19512.25.camel@localhost>
	 <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com>
	 <1215456693.19512.36.camel@localhost>
	 <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753850AbYGGUvW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2008 16:51:22 -0400
In-Reply-To: <76bd70e30807071244v4db1c366uc7599d2dd806bf1b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:

> If you would like connected UDP, I won't object to you implementing
> it.  However, I never tested whether a connected UDP socket will give
> the desired semantics without extra code in the UDP transport (for
> example, an ->sk_error callback).  I don't think it's worth the hassle
> if we have to add code to UDP that only this tiny use case would need.
> 

OK. I'll set these patches aside until I have time to look into adding
connected UDP support.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
