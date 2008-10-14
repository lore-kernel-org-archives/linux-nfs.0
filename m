From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 09:23:57 -0400
Message-ID: <1223990637.8907.3.camel@localhost>
References: <48F3D106.9020203@yadan.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39113 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbYJNNYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2008 09:24:00 -0400
In-Reply-To: <48F3D106.9020203-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-10-14 at 00:51 +0200, Omry Yadan wrote:
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
> 
> if I sleep for 1 second and try again, it works.

What version of nfs, filesystem on the server, export options, mount
options,...?

Cheers
  Trond

