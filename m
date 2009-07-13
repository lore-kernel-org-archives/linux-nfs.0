Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56087 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523AbZGMQUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2009 12:20:15 -0400
Subject: Re: Security negotiation
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Tom Haynes <tdh@excfb.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <4A5B5BCC.5040200@excfb.com>
References: <4A578372.1020005@excfb.com>
	 <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com>
	 <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>
	 <4A57AADE.8080002@excfb.com>
	 <2BA1057E-5A8E-4780-B8F2-FCC8BA3846CC@oracle.com>
	 <4A57C2F3.4070109@excfb.com>
	 <1247265922.8254.30.camel@heimdal.trondhjem.org>
	 <4A5B5BCC.5040200@excfb.com>
Content-Type: text/plain
Date: Mon, 13 Jul 2009 12:20:07 -0400
Message-Id: <1247502007.14524.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2009-07-13 at 11:07 -0500, Tom Haynes wrote:
> Trond Myklebust wrote:
> > On Fri, 2009-07-10 at 17:38 -0500, Tom Haynes wrote:
> >   
> >> If they have the same access lists, then the server is free to order them...
> >>
> >> share -F nfs -o sec=sys:none:krb5,rw /foo
> >> share -F nfs -o sec=sys,ro,sec=krb5p,rw,root=@192.168.2.0,sec=krb5,rw /bar
> >>
> >> In the first, we don't care how the server presents them. In the second, 
> >> the list would be: sys krb5p krb5.
> >>     
> >
> > Meaning that the client defaults to read-only access?
> >
> > Trond
> >   
> 
> In this scenario, yes.
> 
> The export states that if you can't be bothered to run kerberos, I can't 
> be bothered to let you write
> to my filesystem.

Well, how does the security negotiating NFSv3 client discover that?

I'm assuming that in the case of NFSv4, you would return
NFS4ERR_WRONGSEC if the user attempts to write to the server, but what
do you do in the case of NFSv3? Do you return an rpc level AUTH_TOOWEAK
error instead?

    Trond

