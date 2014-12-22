Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail03-md.ns.itscom.net ([175.177.155.113]:37809 "EHLO
	mail03-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbaLVJxH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2014 04:53:07 -0500
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
In-Reply-To: <20141219060942.2bf613c2@tlielax.poochiereds.net>
References: <20141217195911.GF9617@fieldses.org> <20141217200153.GG9617@fieldses.org> <12689.1418917838@jrobl> <20141218155838.GD18179@fieldses.org> <13170.1418920034@jrobl> <20141218231548.GF15665@dastard> <6944.1418957186@jrobl> <20141219060942.2bf613c2@tlielax.poochiereds.net>
Date: Mon, 22 Dec 2014 18:53:02 +0900
Message-ID: <12237.1419241982@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Jeff Layton:
> ...that can only happen in a remote filesystem. The only way for that
> to occur on a local fs is for that fs to allow a directory to be
> hardlinked, which should of course never happen.
>
> As to whether ESTALE is as good as EBUSY there...I doubt it'll matter
> much. Remote filesystems generally have to be able to cope with ESTALE
> errors anyway, and I doubt a lot of userland code handles EBUSY
> especially for this situation.

Ok, I understand.
Thank for explanation.


J. R. Okajima
