From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Security negotiation
Date: Fri, 10 Jul 2009 18:45:22 -0400
Message-ID: <1247265922.8254.30.camel@heimdal.trondhjem.org>
References: <4A578372.1020005@excfb.com>
	 <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com>
	 <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>
	 <4A57AADE.8080002@excfb.com>
	 <2BA1057E-5A8E-4780-B8F2-FCC8BA3846CC@oracle.com>
	 <4A57C2F3.4070109@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50702 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbZGJWpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2009 18:45:33 -0400
In-Reply-To: <4A57C2F3.4070109-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-07-10 at 17:38 -0500, Tom Haynes wrote:
> Chuck Lever wrote:
> > On Jul 10, 2009, at 4:55 PM, Tom Haynes wrote:
> >
> >> The second option would push AUTH_NONE to the end of the list, which
> >> corresponds to my thinking of it as a wild card.
> >
> > The problem with the server's auth list is that it is a list of _all_ 
> > flavors that the server supports.  
> 
> For us it is a list of flavors supported on that export.
> 
> Our default export is basically sec=sys,rw.
> 
> To get all of the flavors, the admin would have to configure them in.
> 
> >
> > I was wondering when a server would not want to order the flavor list 
> > by strongest to weakest.  We have the use case of the kerberos 5 
> > pseudoflavors:  clients should probably use krb5 over krb5p by 
> > default, as this provides good security without a lot of performance 
> > overhead.  But krb5p is stronger security than krb5.
> 
> When they have different access lists.
> 
> If they have the same access lists, then the server is free to order them...
> 
> share -F nfs -o sec=sys:none:krb5,rw /foo
> share -F nfs -o sec=sys,ro,sec=krb5p,rw,root=@192.168.2.0,sec=krb5,rw /bar
> 
> In the first, we don't care how the server presents them. In the second, 
> the list would be: sys krb5p krb5.

Meaning that the client defaults to read-only access?

Trond

