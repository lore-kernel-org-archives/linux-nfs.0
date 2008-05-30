From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Fri, 30 May 2008 12:40:31 -0400
Message-ID: <20080530164031.GA16879@fieldses.org>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com> <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Lentini <jlentini@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47336 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbYE3Qk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2008 12:40:57 -0400
In-Reply-To: <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 30, 2008 at 11:09:19AM -0400, Chuck Lever wrote:
...
> In fact, since 1.1.2 is now available, why even mention 1.1.1 in the  
> instructions?  It would nicely simplify the text if you start with  
> 1.1.2, and the scourge (or ridiculousness?) of the "-i" option need  
> never be mentioned again.

Yeah, I'm with Chuck.  If you really want to handle the 1.1.1 case,
maybe it could be stashed away in a footnote at the end?

And ditto here:

...
> It's worth mentioning that several distributions already ship with  
> 1.1.2, so on modern systems, this build step is probably not needed.

The older distro's will go away eventually, so I'd aim for what will be
the most common (and simplest) case, and move the rest to an
appendix.

--b.

>
> Also, I would use a standard shell prompt in the examples (say, "$ " or 
> "% ", or "# " as necessary, instead of "> "), but that's just me.
>
>>     To verify that the mount is using RDMA, run "cat /proc/mounts" and 
>> check the
>>     "proto" field for the given mount.
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
