Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53694 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758523Ab3LFSJA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 13:09:00 -0500
Date: Fri, 6 Dec 2013 10:08:58 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, xfs@oss.sgi.com,
        linux-nfs@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>
Subject: Re: nfs vs xfstests 193
Message-ID: <20131206180858.GA2803@infradead.org>
References: <20131106115648.GA24804@infradead.org>
 <52A1CF22.106@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A1CF22.106@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 06, 2013 at 05:20:34PM +0400, Stanislav Kholmanskikh wrote:
> Just to make the behaviour more consistent between NFS and other
> "local" file systems as It was done by
> commit https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=0953e620de0538cbd081f1b45126f6098112a598

Seems like we got others in line with XFS behavior.  I'd prefer to
have NFS follow this as well.

