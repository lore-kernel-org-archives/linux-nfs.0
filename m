Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33541 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbaGJNQv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 09:16:51 -0400
Date: Thu, 10 Jul 2014 06:16:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710131650.GA6806@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
 <20140710103100.GA6935@infradead.org>
 <20140710081912.4af7c35b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710081912.4af7c35b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, feel free do drop my comments re the access/deny bitmap.  I don't
really think this is worth it to avoid the small false positive to
allow downgrading if a different open owner had a r/o or w/o open, but
it's probably indeed way to much churn for this series to do anything
about it.

