From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH 0/18] export operations rewrite
Date: Sun, 13 May 2007 21:43:32 +0100
Message-ID: <20070513204332.GB13563@infradead.org>
References: <20070317010946.GA24947@infradead.org> <1175439805.3122.332.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1175439805.3122.332.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, Apr 01, 2007 at 04:03:25PM +0100, David Woodhouse wrote:
> On Sat, 2007-03-17 at 01:09 +0000, Christoph Hellwig wrote:
> > This touches all nfs exporting filesystems, and I've done testing
> > on all of the filesystems I have here locally (xfs, ext2, ext3,
> > reiserfs, jfs) 
> 
> modprobe mtdram ; mount -tjffs2 mtd0 /mnt

There's no nfs exporting support in mainline for jffs2.  And yes, I didn't
forget my promise to help you sorting out how to do it properly, but I'm
a it too busy right now - I'll do it after I've fixed up the issues with
this patch series.

