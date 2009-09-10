From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS slow to respond on resumption from hibernate
Date: Thu, 10 Sep 2009 13:00:40 -0400
Message-ID: <1252602040.8722.128.camel@heimdal.trondhjem.org>
References: <loom.20090910T180831-552@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Orion Poplawski <orion@cora.nwra.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56390 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbZIJRAk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 13:00:40 -0400
In-Reply-To: <loom.20090910T180831-552-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-10 at 16:15 +0000, Orion Poplawski wrote:
> I've started hibernating some of our Fedora desktop machines.  Problem is that
> we have NFS mounted home (and some other) directories and access to these can be
> *slow* (several minutes) to recover on resumption from hibernate.  Other network
> activity is fine.  Fedora bug is here:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=510536
> 
> Any thoughts on what might be causing this or how to debug?

Start by upgrading to the very latest Fedora kernel, which is 2.6.30
based. There are a couple of RPC/tcp reconnection fixes there that
didn't make it into 2.6.29.

Cheers
  Trond

