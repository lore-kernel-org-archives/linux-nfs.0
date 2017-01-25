Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52060 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750768AbdAYTZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jan 2017 14:25:54 -0500
Date: Wed, 25 Jan 2017 14:25:51 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        trondmy@primarydata.com, linux-nfs@vger.kernel.org,
        jlayton@poochiereds.net
Subject: Re: [PATCH v2] nfsd: special case truncates some more
Message-ID: <20170125192551.GD3134@fieldses.org>
References: <d6fd33d2-6323-435c-b085-27a7180c4368@email.android.com>
 <20170124221533.GG20844@fieldses.org>
 <20170125081804.GB14954@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170125081804.GB14954@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2017 at 09:18:04AM +0100, Christoph Hellwig wrote:
> Btw, any rason this didn't go into your for-4.10 tree?  Due to the
> owner/group changes being the most affected attrs I would classify it
> as a security issue.

It only seems to affect a very new setup, and the patch wasn't totally
trivial, so I was inclined to wait and see, but... to be honest I don't
have strong feelings about it, and I respect your opinion--I can queue
it up for-4.10 wth a cc to stable.

(Not attempting to add a Fixes: line as this probably goes very far
back.)

--b.
