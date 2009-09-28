From: Jeff Layton <jlayton@redhat.com>
Subject: Re: "NFS: Buggy server - nlink == 0!" & segfault
Date: Mon, 28 Sep 2009 14:29:27 -0400
Message-ID: <20090928142927.2f994266@tlielax.poochiereds.net>
References: <4ABFC530.4060504@hep.upenn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Andy Mastbaum <mastbaum-q5nx0x9Hqjyyum0STUha2w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbZI1S3b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2009 14:29:31 -0400
In-Reply-To: <4ABFC530.4060504-q5nx0x9Hqjyyum0STUha2w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 27 Sep 2009 16:04:00 -0400
Andy Mastbaum <mastbaum-q5nx0x9Hqjyyum0STUha2w@public.gmane.org> wrote:

> Hello. I have a bunch of Linux (2.6.18-128.1.1.el5, RHEL 5.3) boxen that 
> mount NFS shares from Solaris, and one died recently in a conflagration 
> of kernel segfaults following an NFS error:
> 
> Sep 11 19:37:12 nubar6 kernel: NFS: Buggy server - nlink == 0!
> Sep 11 19:47:57 nubar6 kernel: gdb[28311]: segfault at 00002b4888e73c0b 
> rip 0000000000508f20 rsp 00007fff4112c988 error 4
> Sep 11 19:55:42 nubar6 kernel: NFS: Buggy server - nlink == 0!
> Sep 11 19:55:42 nubar6 kernel: NFS: Buggy server - nlink == 0!
> Sep 11 20:10:27 nubar6 kernel: NFS: giant filename in readdir (len 201)!
> Sep 11 20:10:42 nubar6 kernel: NFS: giant filename in readdir (len 201)!
> ...
> Sep 11 20:36:12 nubar6 kernel: gdb[21443]: segfault at 00002aec9e92d90c 
> rip 000000000050be3e rsp 00007fff6fa92250 error 4
> Sep 11 22:09:42 nubar6 kernel: gdb[6258]: segfault at 000000010b7023b5 
> rip 0000000000508ea0 rsp 00007fff8d39da88 error 4
> ...
> 
> Perhaps the Solaris NFS server is indeed buggy, but shouldn't this be 
> caught/handled by the Linux NFS client? Any thoughts/suggestions?
> 
> Thanks!
> 

Did the kernel actually spew an oops as well?

>From what you've posted here, it doesn't look like the kernel panicked.
If not, then I suspect that the userspace programs doing the readdir
weren't expecting filenames as large as those that were returned.

As to why that happened in the first place, it's also hard to say. I
suspect that the data that he client was trying to parse was corrupt.
Either the server sent a corrupt response to the readdir, or something
happened to throw the alignment off and cause the response parser to
fall down.

Either way, we probably wouldn't be able to tell w/o more info. A
reliable way to reproduce it would be helpful.

-- 
Jeff Layton <jlayton@redhat.com>
