Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53502 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3KGQiy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 11:38:54 -0500
Date: Thu, 7 Nov 2013 08:38:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Message-ID: <20131107163854.GA21919@infradead.org>
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
 <20131107155837.GA16658@infradead.org>
 <20131107110928.68244ea7@tlielax.poochiereds.net>
 <20131107162123.GA9411@infradead.org>
 <20131107113310.567c3b64@tlielax.poochiereds.net>
 <20131107163520.GA17857@infradead.org>
 <20131107113656.33034055@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131107113656.33034055@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 07, 2013 at 11:36:56AM -0500, Jeff Layton wrote:
> No idea then, sorry...

4.0 is also affected, interestingly it's only reproducible on the first
mount of a volume after the server started, so I'll assume a server
issue.  I'm trying to drill it down time permitting, but so far I have
no clue what's going on.  Doesn't help that recent versions of
latencytop are unusable..

