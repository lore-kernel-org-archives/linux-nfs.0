Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52190 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516AbbCENRf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 08:17:35 -0500
Date: Thu, 5 Mar 2015 14:17:31 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150305131731.GA16235@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150303224456.GV4251@dastard> <20150304020826.GD19439@fieldses.org> <20150304155421.GE1627@fieldses.org> <20150304220900.GX18360@dastard> <20150304222709.GI1627@fieldses.org> <20150304224557.GY4251@dastard> <54F78BE5.1020608@sandeen.net> <20150304225623.GZ4251@dastard> <20150305040849.GJ1627@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150305040849.GJ1627@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2015 at 11:08:49PM -0500, J. Bruce Fields wrote:
> Ah-hah:
> 
> 	static void
> 	nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
> 	{
> 		...
> 		nfsd4_cb_layout_fail(ls);
> 
> That'd do it!
> 
> Haven't tried to figure out why exactly that's getting called, and why
> only rarely.  Some intermittent problem with the callback path, I guess.
> 
> Anyway, I think that solves most of the mystery....

Ooops, that was a nasty git merge error in the last rebase, see the fix
below.  But I really wonder if we need to make the usage of pnfs explicit
after all, othterwise we'll always hand out layouts on any XFS-exported
filesystems, which can't be used and will eventually need to be recalled.

---
