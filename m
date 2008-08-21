From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Server bottleneck(?) due to large record write() buffer size
	from client app
Date: Thu, 21 Aug 2008 12:20:17 -0700
Message-ID: <1219346417.7052.36.camel@localhost>
References: <48AB9A2F.1050005@cse.unsw.edu.au>
	 <1219259723.7547.26.camel@localhost>  <48ACCD61.60504@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55432 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754805AbYHUTUV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2008 15:20:21 -0400
In-Reply-To: <48ACCD61.60504-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-08-21 at 12:05 +1000, Shehjar Tikoo wrote:
> By changing pdflush settings on the client, I'd be changing the
> settings for the whole system. Is there a proc FS entry or any other 
> config param that lets me lower the number of write requests buffered
> at client before the commit request is sent?

Write buffering is not something which is under the control of the NFS
filesystem: it is entirely managed by the VM. The filesystem only
enforces the close-to-open cache consistency requirements, which of
course are specific to NFS.

Trond

