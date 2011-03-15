Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47617 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752230Ab1COVmD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 17:42:03 -0400
Date: Tue, 15 Mar 2011 17:42:03 -0400
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and NFSv4.1 client recovery
Message-ID: <20110315214203.GC2292@fieldses.org>
References: <4D7F80C0.2020405@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D7F80C0.2020405@cea.fr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 15, 2011 at 04:07:44PM +0100, DENIEL Philippe wrote:
> Hi,
> 
> as you may know, I am working on a NFS server in user space called
> nfs-ganesha. One of the feature of nfs-ganesha is its capability of
> being used as a NFSv4 proxy. This is implemented as a backend in
> nfs-ganesha : all the filesystem that nfs-ganesha can export have a
> dedicated module with a well known API (this module is called FSAL
> for File System Abstraction layer). The proxy feature is made by
> make a FSAL library that is a NFSv4 basic client (each of the FSAL
> functions calls wrap one or more NFSv4 request). The trouble is the
> case when the remote server (the one accessed by the proxy operating
> as a client via FSAL calls) crashes : the client inside the FSAL
> needs to recover to the remote server as it comes back to work. My
> question is : what is the simpliest way for my user space client to
> recover ? I must precise it make no delegation and use only a
> forechannel to the remote server. There is no backchannel.

I suppose you could either try to do the recovery yourself on the proxy,
or pass back the STALE errors to the original client and make it drive
the recovery.  Maybe either way will work?

If you did the latter then I suppose your API would have to support
allowing proxy module to report a reboot, and allow passing reclaims
down.

I dunno.

--b.
