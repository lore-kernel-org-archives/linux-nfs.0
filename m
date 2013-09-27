Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753120Ab3I0UJm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Sep 2013 16:09:42 -0400
Date: Fri, 27 Sep 2013 16:09:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jongman Heo <jongman.heo@samsung.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Re: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add
 NFS v4.2 support to the NFS server")
Message-ID: <20130927200939.GB22640@fieldses.org>
References: <15262316.12141380248492298.JavaMail.weblogic@epml04>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <15262316.12141380248492298.JavaMail.weblogic@epml04>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 27, 2013 at 02:21:33AM +0000, Jongman Heo wrote:
> Hi,
> 
> >
> >------- Original Message -------
> >Sender : J. Bruce Fields<bfields@fieldses.org>
> >Date : 2013-09-27 10:12 (GMT+09:00)
> >Title : Re: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS v4.2 support to the NFS server")
> >
> >On Thu, Sep 26, 2013 at 11:57:57PM +0000, Jongman Heo wrote:
> >> >------- Original Message -------
> >> >Sender : J. Bruce Fields
> >> >This is pretty weird--it's not at all obvious how that patch would
> >> >affect this.
> >> >
> >> >You're absolutely positive that the *only* thing you're changing on the
> >> >server between the "good" and "bad" cases is that one kernel patch?
> >> >You're not changing anything in userspace?
> >> >
> >> 
> >> Yes, pretty sure.
> >> 
> >> >What does "cat /proc/fs/nfsd/versions" report in the good and bad cases?
> >> >
> >> >(BTW, out of curiosity: what kind of client is this that only supports
> >> >NFSv2 and NFSv3?  Even for an embedded system that's a bit surprising.)
> >> >
> >> >--b.
> >> >
> >> 
> >> Here are /proc/fs/nfsd/versions information for good and bad cases ;
> >> 
> >> good (commit 4bdc33ed reverted)
> >> 
> >> # cat /proc/fs/nfsd/versions 
> >> +2 +3 +4 +4.1
> >> 
> >> 
> >> bad (current linus git)
> >> 
> >> # cat /proc/fs/nfsd/versions  
> >> -2 +3 +4 +4.1 -4.2
> >> 
> >> 
> >> I don't know why the commit 4bdc33ed makes this difference ( from +2 to -2 ).
> >> 
> >> My NFS server just uses Fedora 19 + latest kernel (which is not a rare setup...), 
> >
> >The thing is, nfs-utils *did* make exactly this change with commit
> >6b4e4965a6b82e8d49cea1c0316b951ba4e9e83e "rpc.nfsd: No longer advertise
> >NFS v2 support." in 1.2.9-rc4 which entered f19 recently.  And that
> >kernel commit doesn't look related.  So I strongly suspect that you got
> >the nfs-utils update (or rebooted after the update) at the same time as
> >bisecting, and that confused the bisect results.
> >
> 
> No, I haven't changed/upgraded nfs-utils package during git bisect.

Well, all it would take would be a long-ago yum update that you'd
forgotten about by the time you rebooted to a new kernel at which point
the new rpc.nfsd behavior would take affect on restarting the nfs
server.

> And I can still reproduce the issue.

So I'm still really skeptical but if you're positive then I guess I
should go try to reproduce and make sure there's not something very
screwed up with the nfsd/versions interface.

--b.
