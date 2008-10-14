From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 13:10:32 -0400
Message-ID: <20081014171032.GA17899@fieldses.org>
References: <48F3D106.9020203@yadan.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34915 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbYJNRKe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2008 13:10:34 -0400
In-Reply-To: <48F3D106.9020203-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 14, 2008 at 12:51:50AM +0200, Omry Yadan wrote:
> I have an application that open many files for writing very fast, in a
> way - it can almost be looked as a file system stress test.
> 
> 
> my application is single threaded, and I noticed the following problem
> when running a single instance of it:
> 
> 
> at some point, after opening (and closing) many files for writing, the
> application fails to open a file for writing.

Do you know what error exactly the open is failing with?

--b.

> if I sleep for 1 second and try again, it works.
> 
> 
> my NFS server runs Debian etch 32 bit, with
> 
> nfs-kernel-server and nfs-common (1:1.0.10-6+etch.1).
> 
> 
> client is also etch 32.
> 
> kernel on both is :2.6.18-6-686 #1 SMP Tue Jun 17 21:31:27 UTC 2008 i686
> 
> 
> both machines are quad core.
> 
> 
> 
> I tried to mount with tcp and udp, and tried both sync and async export
> point.
> 
> 
> is this a known issue?
> 
> any known workaround that will not require messing up the application
> with retry logic?
> 
> 
>     Omry.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
