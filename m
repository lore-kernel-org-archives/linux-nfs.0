From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sat, 09 Aug 2008 20:55:10 +0100
Message-ID: <1218311710.26926.125.camel@pmac.infradead.org>
References: <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <18581.40178.976747.769343@notabene.brown>
	 <76bd70e30808031015l36db41bexf319e85ba7acc4e9@mail.gmail.com>
	 <18582.21855.2092.903688@notabene.brown>
	 <76bd70e30808032319u65e35dbdj9cc5be07e1aef829@mail.gmail.com>
	 <20080805085157.GG21635@disturbed>
	 <18584.56584.98868.881298@notabene.brown>
	 <20080806000805.GJ21635@disturbed>  <20080806195635.GA31126@fieldses.org>
	 <1218053443.5111.148.camel@pmac.infradead.org>
	 <1218300478.26926.114.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1218300478.26926.114.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-08-09 at 17:47 +0100, David Woodhouse wrote:
> Here it is in a single patch...

Updated again after more feedback from hch, to really make it
unconditional instead of just inverting the logic, turn a check for
S_ISDIR() in JFFS2 into a BUG_ON() because it should _really_ never
happen, and fix up some comments (remove the one about why we do the
buffering in xfs, and add something similar back in nfsd).

{http://,git://} git.infradead.org/users/dwmw2/nfsexport-2.6.git

Patch sequence follows...

-- 
dwmw2

