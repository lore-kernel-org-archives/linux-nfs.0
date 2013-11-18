Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39019 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab3KRRXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 12:23:18 -0500
Date: Mon, 18 Nov 2013 09:23:15 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118172315.GA20339@infradead.org>
References: <20131118124406.GA46678@colin.muc.de>
 <20131118130026.GA4153@infradead.org>
 <20131118170132.GD3203@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118170132.GD3203@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 12:01:32PM -0500, J. Bruce Fields wrote:
> Just tracing a v3 mount I can confirm that S_IFDIR (0x4000, 040000)
> gets set in GETATTR replies.

Oh. got it.  We set the stat file type, nothing related to the 32-bit
readdir cookie.

> Anyway, absent objections my default is to queue this up for 3.14 (using
> S_IALLUGO).

Yeah, that part looks good to me.  But it seem Albert still has an issue
with the directory offsets.  Might be worth to get the ext4 developes
in the loop for that, as I doubt it's an issue with the nfsd code.

