From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] Reinstate NFS exportability
Date: Sat, 9 Aug 2008 16:10:56 -0400
Message-ID: <20080809201056.GD8181@infradead.org>
References: <18582.21855.2092.903688@notabene.brown> <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com> <20080805085157.GG21635@disturbed> <18584.56584.98868.881298@notabene.brown> <20080806000805.GJ21635@disturbed> <20080806195635.GA31126@fieldses.org> <1218053443.5111.148.camel@pmac.infradead.org> <1218300478.26926.114.camel@pmac.infradead.org> <1218311710.26926.125.camel@pmac.infradead.org> <1218312213.5063.9.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:57571 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbYHIULA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2008 16:11:00 -0400
In-Reply-To: <1218312213.5063.9.camel-ZP4jZrcIevRpWr+L1FloEB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 09, 2008 at 09:03:33PM +0100, David Woodhouse wrote:
> Now that the readdir/lookup deadlock issues have been dealt with, we can
> export JFFS2 file systems again.

Looks good, but you might want to add a comment why jffs2 doesn't
care about an inode generation number.

