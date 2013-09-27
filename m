Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab3I0BMq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 21:12:46 -0400
Date: Thu, 26 Sep 2013 21:12:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jongman Heo <jongman.heo@samsung.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS
 v4.2 support to the NFS server")
Message-ID: <20130927011246.GA10245@fieldses.org>
References: <26120922.5161380239877162.JavaMail.weblogic@epml04>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <26120922.5161380239877162.JavaMail.weblogic@epml04>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 11:57:57PM +0000, Jongman Heo wrote:
> >------- Original Message -------
> >Sender : J. Bruce Fields<bfields@fieldses.org>
> >This is pretty weird--it's not at all obvious how that patch would
> >affect this.
> >
> >You're absolutely positive that the *only* thing you're changing on the
> >server between the "good" and "bad" cases is that one kernel patch?
> >You're not changing anything in userspace?
> >
> 
> Yes, pretty sure.
> 
> >What does "cat /proc/fs/nfsd/versions" report in the good and bad cases?
> >
> >(BTW, out of curiosity: what kind of client is this that only supports
> >NFSv2 and NFSv3?  Even for an embedded system that's a bit surprising.)
> >
> >--b.
> >
> 
> Here are /proc/fs/nfsd/versions information for good and bad cases ;
> 
> good (commit 4bdc33ed reverted)
> 
> # cat /proc/fs/nfsd/versions 
> +2 +3 +4 +4.1
> 
> 
> bad (current linus git)
> 
> # cat /proc/fs/nfsd/versions  
> -2 +3 +4 +4.1 -4.2
> 
> 
> I don't know why the commit 4bdc33ed makes this difference ( from +2 to -2 ).
> 
> My NFS server just uses Fedora 19 + latest kernel (which is not a rare setup...), 

The thing is, nfs-utils *did* make exactly this change with commit
6b4e4965a6b82e8d49cea1c0316b951ba4e9e83e "rpc.nfsd: No longer advertise
NFS v2 support." in 1.2.9-rc4 which entered f19 recently.  And that
kernel commit doesn't look related.  So I strongly suspect that you got
the nfs-utils update (or rebooted after the update) at the same time as
bisecting, and that confused the bisect results.

> so I think some people can verify if this version information change happens w/ and w/o the commit revert.
> 
> Don't know the detail of NFS protocol, but our NFS client seems not to try with v3 and v4 in case v2 fails...
> Is this an unexpected (buggy) behavior of my old embedded box (NFS client of kernel 2.6.35), or expected one from the NFS protocol?

Digging into a historical git repo just for fun.... It looks like NFSv3
support was added in 2.3.99pre4-3, probably in 2000?  (The date on that
commit is 2007, so obviously this repo I have is very confused.  Maybe I
should go find if there's a better one someplace.)

So anyway it's either configured out of the kernel or the mount
commandline's asking for v2, or I don't know what....

--b.
