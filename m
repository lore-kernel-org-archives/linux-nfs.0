From: Leonardo Chiquitto <leonardo.lists@gmail.com>
Subject: Re: [PATCH] NFS: Fix send buffer length calculation in
	nfs3_xdr_setaclargs()
Date: Wed, 15 Apr 2009 17:11:32 -0300
Message-ID: <c2d0b6ec0904151311x4c66f3d6t9eaacd330792fbbc@mail.gmail.com>
References: <49E5EAE6.7000507@suse.de>
	 <1239818456.5177.88.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:31339 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbZDOULe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 16:11:34 -0400
Received: by qw-out-2122.google.com with SMTP id 8so93894qwh.37
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2009 13:11:33 -0700 (PDT)
In-Reply-To: <1239818456.5177.88.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Please check if the following patch fixes things for you.
>
> Trond
> ------------------------------------------------------------
> >From b273b42f8b793a4a446015b50a5c1473553af48b Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 15 Apr 2009 13:58:45 -0400
> Subject: [PATCH] NFS: Fix the XDR iovec calculation in nfs3_xdr_setaclargs
>
> Commit ae46141ff08f1965b17c531b571953c39ce8b9e2 (NFSv3: Fix posix ACL code)
> introduces a bug in the calculation of the XDR header iovec. In the case
> where we are inlining the acls, we need to adjust the length of the iovec
> req->rq_svec, in addition to adjusting the total buffer length.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I just tested and it fixes the problem for me.

Thanks!
Leonardo
