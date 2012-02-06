Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754865Ab2BFQjt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 11:39:49 -0500
Date: Mon, 6 Feb 2012 11:39:46 -0500
To: Jim Rees <rees@umich.edu>
Cc: Liam Gretton <liam.gretton@leicester.ac.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
Message-ID: <20120206163945.GA29579@fieldses.org>
References: <4F2A2F9E.6030908@steve-ss.com>
 <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
 <4F2D9A0E.6010503@leicester.ac.uk>
 <4F2E4B50.5040701@steve-ss.com>
 <20120205141611.GA12826@umich.edu>
 <4F2EB471.9060508@leicester.ac.uk>
 <20120205173728.GA13418@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120205173728.GA13418@umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 05, 2012 at 12:37:28PM -0500, Jim Rees wrote:
> Liam Gretton wrote:
> 
>   On 05/02/2012 14:16, Jim Rees wrote:
>   >There is a a NFS wiki, and it does have kerberos setup instructions:
>   >http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
>   >
>   >The wiki has mostly been used by developers for developer info but it might
>   >be a good thing to use it for more general info too.
>   
>   Thanks, the problem isn't getting NFS with Kerberos to work in
>   general, it's with AD as the KDC. It seems that NFS still only
>   accepts DES encrypted Kerberos tickets, and these are specifically
>   disabled in Windows Server 2008 R2.
> 
> Wasn't that fixed recently?

Yes, it supports some AES-based enctypes now, for example.  I wouldn't
know a better source of the details than

	git log net/sunrpc/auth_gss/gss_krb5_*

If someone wanted to summarize the situation for the wiki, go for it.

--b.
