Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60725 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab3KXN3C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Nov 2013 08:29:02 -0500
Date: Sun, 24 Nov 2013 05:29:00 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131124132900.GA18413@infradead.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
 <20131124130753.GA15178@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131124130753.GA15178@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 24, 2013 at 08:07:53AM -0500, Jim Rees wrote:
> Maybe we're just trying to avoid collisions, and don't care if someone can
> guess xids? But either way, agreed. Also, shouldn't the existence of
> arc4random() be determined by configure? Isn't that why we use configure, so
> we don't need fragile ifdefs in the code?
> 
> Is anyone maintaining this library?

No idea.  But the easiest would be to just link against libbsd on Linux
to get the BSDish arc4random symbol.
