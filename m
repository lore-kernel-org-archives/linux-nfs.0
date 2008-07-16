From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv4 and nfsroot
Date: Wed, 16 Jul 2008 09:09:31 -0400
Message-ID: <1216213771.7786.7.camel@localhost>
References: <487D7230.2050404@neuralbs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: kyron-PfIpIgFSuk5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47223 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119AbYGPNJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 09:09:35 -0400
In-Reply-To: <487D7230.2050404-PfIpIgFSuk5Wk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-07-15 at 23:59 -0400, Eric Thibodeau wrote:
> I've set up nfsroot based systems before but I am now attempting to do 
> the same thing using nfsv4 using the _in-kernel_ nfsroot support (ie: no 
> initrd with script that does the mounting). I have been unable to find 
> "authoritative" references to how to accomplish this and wanted to ask 
> for solid references before I start polluting the mailing list with my 
> probably completely erroneous approach. Things that might be worth 
> mentioning:

nfsroot for NFSv4 is not supported. You can still do it by using an
initrd file in order to bootstrap the necessary user-space utilities
like the idmapper (and possibly rpc.gssd) before mounting the partition
and pivoting.

Cheers
  Trond

