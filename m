Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52589 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab1HAOmH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 10:42:07 -0400
Subject: Re: using non contiguous memory in nfs_idmap_new()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Adrien Kunysz <adk@acunu.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 01 Aug 2011 10:42:11 -0400
In-Reply-To: <CAA4Z2ZR47Lfb_=172VUd-Qop7NiC3ewVAgUepn0WD=PDTr9k-A@mail.gmail.com>
References: <CAA4Z2ZR47Lfb_=172VUd-Qop7NiC3ewVAgUepn0WD=PDTr9k-A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312209731.9421.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-01 at 14:54 +0100, Adrien Kunysz wrote: 
> Dear linux-nfs,
> 
> I have a box that has recently been victim of an OOM caused by
> nfs_idmap_new() attempting to allocate a large amount of contiguous
> memory. This problem has been reported previously here [0] and I
> understand the real fix is to use CONFIG_NFS_USE_NEW_IDMAPPER. However
> I was wondering whether using non contiguous memory instead would be a
> valid workaround, especially considering the new ID mapper is not
> enabled by default. I have actually written a patch to that effect as
> I don't see any specific reason why that struct would need to be in
> contiguous memory.
> 
> So before I do anything stupid with that patch,
> a) is there any good reason to use kzalloc() instead of vzalloc() in
> nfs_idmap_new()?

vmalloc memory is a limited resource too.

> b) would you consider a patch that would make the function use vzalloc()?

Is there any reason why you can't use the new idmapper now that it has
been integrated into the upstream nfs-utils? There are so many
scalability issues with the old idmapper that I'd rather deprecate its
use as quickly as possible.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

