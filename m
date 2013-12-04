Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43942 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932290Ab3LDNNS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 08:13:18 -0500
Date: Wed, 4 Dec 2013 05:13:17 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131204131317.GA7776@infradead.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
 <20131124130753.GA15178@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131124130753.GA15178@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
last upstream release is a tarball drop from CITI in 2009 and there
doesn't appear to be a source repository of any kind.

I think the best idea would be to merge it into the libtirpc repo,
as both the heritage and usage of the codebases is the same.

