From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Wed, 6 Aug 2008 15:56:35 -0400
Message-ID: <20080806195635.GA31126__18297.7421246052$1218052722$gmane$org@fieldses.org>
References: <1217607571.3454.417.camel@pmac.infradead.org> <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com> <20080802182644.GE30454@fieldses.org> <18581.40178.976747.769343@notabene.brown> <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com> <18582.21855.2092.903688@notabene.brown> <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com> <20080805085157.GG21635@disturbed> <18584.56584.98868.881298@notabene.brown> <20080806000805.GJ21635@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	David Woodhouse <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org,
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56587 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbYHFT4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Aug 2008 15:56:46 -0400
In-Reply-To: <20080806000805.GJ21635@disturbed>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So the only solution that seems to really be holding up (at least for
the near term) is the double-buffering "hack"; could we get a version of
that with Neil's review comments addressed?

--b.
