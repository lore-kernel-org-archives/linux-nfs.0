From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Wed, 06 Aug 2008 21:10:43 +0100
Message-ID: <1218053443.5111.148.camel@pmac.infradead.org>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, chucklever@gmail.com,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080806195635.GA31126@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-06 at 15:56 -0400, J. Bruce Fields wrote:
> So the only solution that seems to really be holding up (at least for
> the near term) is the double-buffering "hack"; could we get a version
> of that with Neil's review comments addressed?

git.infradead.org/users/dwmw2/nfsexport-2.6.git

I inverted the logic so that the file system has to set a
FS_LOOKUP_IN_READDIR flag to avoid the hack, rather than setting a
FS_NO_LOOKUP_IN_READDIR flag to _use_ it. Renamed it so that it doesn't
say 'hack', took out the loop to allocate memory.

Tasks left for someone more familiar with the NFS code are: 
 - making it use one of the pages already allocated for the response.
 - giving it a hint about how many dirents to read into the buffer.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



