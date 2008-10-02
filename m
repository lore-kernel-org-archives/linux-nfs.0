From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Thu, 2 Oct 2008 13:17:19 -0400
Message-ID: <20081002171719.GA30408@fieldses.org>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Roy M." <setesting001@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbYJBRRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2008 13:17:21 -0400
In-Reply-To: <beaf78240810020949j703d95cvab1c44f33bff7019-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 03, 2008 at 12:49:50AM +0800, Roy M. wrote:
> Hello,
> 
> We are just using v3 for quite a long time, very stable, performance
> are not bad but like many others, want to explore if possible to have
> a better throughput.

Raw throughput should be the same.  And I think the little benchmarking
I've seen has found that to be true.

If you're just doing big I/O to a few files, that may be all you care
about.  If you're doing something more complicated then the situation
isn't well understood yet.

> Seems that are not many benchmark in the web about v4 vs v3 for
> performance, etc. Anyone mind sharing some experience? What are the
> real advantages in using v4?

In theory: if you're doing file locking or reopening files a lot, then
you may see a benefit from v4 delegations (which permit the client in
some situations to do those operations without telling the server), and
I do recall seeing some improvements e.g. with kernel compiles (which
tend to reopen a small set of files frequently).

--b.
