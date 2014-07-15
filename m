Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52254 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbaGOHub (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 03:50:31 -0400
Date: Tue, 15 Jul 2014 00:50:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 003/100] nfsd: Ensure stateids remain unique until
 they are freed
Message-ID: <20140715075029.GA9479@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-4-git-send-email-jlayton@primarydata.com>
 <20140710112342.GB10893@infradead.org>
 <20140710084300.3ef4d466@tlielax.poochiereds.net>
 <20140714124551.391363a1@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140714124551.391363a1@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 14, 2014 at 12:45:51PM -0400, Jeff Layton wrote:
> I've been looking at this and I don't really see much in the way of
> benefit from changing to a set of flags for that sort of thing. I don't
> think it will materially improve the code.
> 
> Currently, we only rarely search for these "secondary" stateid types
> (only in nfsd4_close), and if we add in a set of flags then we have to
> worry about checking them in places where we're searching for "base"
> stateid types today.

Ok.

