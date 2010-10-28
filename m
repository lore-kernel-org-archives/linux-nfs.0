Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9458 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab0J1P1l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 11:27:41 -0400
Message-ID: <4CC9966B.1050103@netapp.com>
Date: Thu, 28 Oct 2010 11:27:39 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-utils: add nfs.idmap
References: <4CC6CE30.90105@netapp.com> <4CC70D34.1060600@netapp.com> <4CC99463.9000108@RedHat.com>
In-Reply-To: <4CC99463.9000108@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/28/2010 11:18 AM, Steve Dickson wrote:
> Hey Bryan,
> 
> A couple nits.... which I will be more than willing to take of... 
> 
> 1) I would like to change the binary name from nfs.idmap to nfsidmap
>    which is consistent with how the rest of the binaries are named.
>    (i.e. binary names generally don't have any '.' or '-' in them)
>    
> 2) Change the source directory from utils/nfs.idmap to 
>    utils/idmap which again makes it consistent with what
>    is already there. 

These both sounds reasonable to me.  I'll make a patch to modify the kernel documentation to reflect this.
> 
> 3) The man page talks about a /usr/sbin/idmap file and then
>    later talks about a /usr/sbin/nfs.idmap program. Can I 
>    assume those are same binary, since I only see on binary
>    being installed? Also, maybe we should move the binary to
>    /sbin so it would be available early in the boot
> 
> Comments?

Yes, those are the same binary.  I don't know how that slipped through, but thanks for catching it.  Making it available early in the boot sounds like it could be useful.  I'll change this in the kernel documentation, too.
> 
> steved.
