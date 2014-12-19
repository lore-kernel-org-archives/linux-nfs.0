Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail01-md.ns.itscom.net ([175.177.155.111]:45093 "EHLO
	mail01-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaLSCq3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 21:46:29 -0500
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
To: Dave Chinner <david@fromorbit.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
In-Reply-To: <20141218231548.GF15665@dastard>
References: <20141217195911.GF9617@fieldses.org> <20141217200153.GG9617@fieldses.org> <12689.1418917838@jrobl> <20141218155838.GD18179@fieldses.org> <13170.1418920034@jrobl> <20141218231548.GF15665@dastard>
Date: Fri, 19 Dec 2014 11:46:26 +0900
Message-ID: <6944.1418957186@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dave Chinner:
> We use file handles on local filesystems. They have exactly the same
> semantics as NFS file handles and so local filesystems have the same
> ESTALE exposure as "distributed" filesystems to this problem. i.e:

It is reasonable.
But do you think ESTALE is good in case of __d_unalias()?


J. R. Okajima
