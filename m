Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53450 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab3KGQVX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 11:21:23 -0500
Date: Thu, 7 Nov 2013 08:21:23 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Message-ID: <20131107162123.GA9411@infradead.org>
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
 <20131107155837.GA16658@infradead.org>
 <20131107110928.68244ea7@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131107110928.68244ea7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 07, 2013 at 11:09:28AM -0500, Jeff Layton wrote:
> It may be the same issue. IIRC, the attempt to use krb5i by default
> is done in the SETCLIENTID call (see kernel commit 4edaa30888 for some
> background, but there were some later tweaks to this approach).

I'm still seing my issue after reverting that commit by hand.
