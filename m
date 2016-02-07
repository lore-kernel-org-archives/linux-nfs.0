Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mondschein.lichtvoll.de ([194.150.191.11]:45256 "EHLO
	mail.lichtvoll.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcBGSZy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2016 13:25:54 -0500
From: Martin Steigerwald <martin@lichtvoll.de>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
Subject: Re: getrichacl(1) man page review comments
Date: Sun, 07 Feb 2016 19:16:40 +0100
Message-ID: <1505883.O2zQ69A2Zb@merkaba>
In-Reply-To: <56B77139.4080209@gmail.com>
References: <56B770B6.7040803@gmail.com> <56B77139.4080209@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Sonntag, 7. Februar 2016, 17:30:49 CET schrieb Michael Kerrisk (man-pages):
> Hello Andreas,
> 
> Here, some comments on the getrichacl(1) page.

I know that the command names are based on setfacl and getfacl. But sometimes 
I still wonder about these names. They just don´t fit.

Its chsomething for changing things in Unix traditionally – chown, chmod, 
chattr, chage chsh, you name it –, but there is nothing for querying things. 
So I get where this is coming from, yet I always found setfacl and getfacl 
command names cumbersome.

Sorry, for posting here instead of a previous richacl implementation patchset. 
I fully appreciate that it may be too late to change anything regarding 
command names. Also considering usermod and groupmod the command naming in 
Unix / Linux appears to be a big mess anyway.

Thanks,
-- 
Martin
