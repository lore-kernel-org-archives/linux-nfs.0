From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: Server bottleneck(?) due to large record write() buffer size
 from client app
Date: Fri, 22 Aug 2008 10:48:47 +1000
Message-ID: <48AE0CEF.7020207@cse.unsw.edu.au>
References: <48AB9A2F.1050005@cse.unsw.edu.au>	 <1219259723.7547.26.camel@localhost>  <48ACCD61.60504@cse.unsw.edu.au> <1219346417.7052.36.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070603040708070500090405"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from note.orchestra.cse.unsw.EDU.AU ([129.94.242.24]:50123 "EHLO
	note.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755799AbYHVBF0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 21:05:26 -0400
In-Reply-To: <1219346417.7052.36.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070603040708070500090405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2008-08-21 at 12:05 +1000, Shehjar Tikoo wrote:
>> By changing pdflush settings on the client, I'd be changing the 
>> settings for the whole system. Is there a proc FS entry or any 
>> other config param that lets me lower the number of write 
>> requests buffered at client before the commit request is sent?
> 
> Write buffering is not something which is under the control of the 
> NFS filesystem: it is entirely managed by the VM. The filesystem 
> only enforces the close-to-open cache consistency requirements, 
> which of course are specific to NFS.

True, but I see that there are atleast two cases where NFS client will
send out the outstanding requests:

1. In nfs_flush_incompatible and through the balanced_rate_limited
code, which is essentially an interface into the VM.

2. In a few other places in VFS, where it sends the requests after
checking whether the file is opened O_SYNC or if the inode is IS_SYNC.

WRT point 2, if its possible to send the requests out explicitly for
these two flags, i.e. O_SYNC or S_SYNC, it might be possible to
optimize the transmit behaviour for large write() record sizes, which
are left uncommitted either:

1. till the full record has been transmitted as UNSTABLE.

2. or till the file is closed.

...resulting in a big flush at the server when the commit does come
in.

See the attached file for the plot of what I am observing. The plot is
based on data for 2.6.26 but I see the same behaviour on 2.6.27-rc3.

Thanks
Shehjar

--------------070603040708070500090405
Content-Type: image/png;
 name="nfs_xfs_recsize_write_128slots_1mwsize.png"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="nfs_xfs_recsize_write_128slots_1mwsize.png"

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
--------------070603040708070500090405--
