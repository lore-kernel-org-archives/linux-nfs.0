Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55062 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932483Ab0E0RzI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 May 2010 13:55:08 -0400
Subject: Re: nfs4 hang
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christopher Hawkins <chawkins@bplinux.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <20100527170829.GA11559@fieldses.org>
References: <2212784.91274721147769.JavaMail.javamailuser@localhost>
	 <18251062.111274721421458.JavaMail.javamailuser@localhost>
	 <20100527170829.GA11559@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 May 2010 13:55:01 -0400
Message-ID: <1274982901.20557.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-05-27 at 13:08 -0400, J. Bruce Fields wrote:
> On Mon, May 24, 2010 at 01:17:01PM -0400, Christopher Hawkins wrote:
> > Thanks Bruce, it does appear that idmapd is somehow related to this
> > issue. However, I'm stumped because it does exist on the client, along
> > with all the libraries it requires (according to ldd, anyway).
> 
> And /etc/passwd, and whatever other files it might decide it needs to
> open to do its work?
> 
> > Is
> > there an easy way to disable idmapd while still running nfs4 to
> > determine if it is causing the hang?
> 
> Not that I know of.

Why would you need to? 'Magic sysrq-trigger t' will show you if the
idmapper is deadlocked inside the NFS filesystem (as will the equivalent
'echo t >/proc/sysrq-trigger').

  Trond

