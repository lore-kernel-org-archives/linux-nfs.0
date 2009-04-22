From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/11] nfsd: ADD data structure infrastructure
Date: Wed, 22 Apr 2009 11:06:33 +0530
Message-ID: <OFC3F6A1EF.6F01ED4C-ON652575A0.001BD4E4-652575A0.001ED00D@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133628.16437.11092.sendpatchset@localhost.localdomain> <20090421224838.GH27411@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:42085 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbZDVFhh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 01:37:37 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3M5bZtK003071
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:07:35 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3M5bkpm4448472
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:07:46 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3M5bXg0001177
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 15:37:34 +1000
In-Reply-To: <20090421224838.GH27411@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/22/2009 04:18:38 AM:

> > +/*
> > + * This is a cache of file handles to quicken file lookup. This also
> > + * helps prevent multiple open/close of a file when a client reads it.
> > + *
> > + * If you increase the number of cached files very much, you'll need
to
> > + * add a hash table here.
>
> I'm a little confused here--what do you mean by "add a hash table here"?

That is also in the original code. I feel the comment is wrong as we
already have a hash table in raparm_hbucket, but I didn't want to change
typos as part of this patch.

thanks,

- KK

