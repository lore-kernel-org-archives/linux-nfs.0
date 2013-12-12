Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47528 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab3LLIOG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 03:14:06 -0500
Date: Thu, 12 Dec 2013 00:13:59 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>,
        linux-nfs@vger.kernel.org, vasily.isaenko@oracle.com,
        hch@infradead.org, xfs@oss.sgi.com, sprabhu@redhat.com
Subject: Re: [PATCH] nfsd: revoking of suid/sgid bits after chown() in a
 consistent way
Message-ID: <20131212081359.GB2325@infradead.org>
References: <20131206204747.GB12613@fieldses.org>
 <1386756996-28083-1-git-send-email-stanislav.kholmanskikh@oracle.com>
 <52A845C6.2080109@oracle.com>
 <20131212033859.GA5978@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131212033859.GA5978@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 11, 2013 at 10:38:59PM -0500, J. Bruce Fields wrote:
> In the v3 case I'd expect the open O_TRUNC to result in a SETATTR rpc,
> in the v4 case an OPEN rpc.  Both result in a call to nfsd_setattr,
> though I only see nfsd_setattr turning off the SUID/SGID bits in the
> chown case.  Are you sure it isn't the subsequent write that clears
> those bits?

We've traditionally cleared the suid bits for O_TRUNC for local
filesystem, although this is more a convention than a real security
need.  It would still be good if NFSv4 would follow the general
semantics.

