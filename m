From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Fri, 24 Apr 2009 09:31:54 -0400
Message-ID: <1240579914.4946.19.camel@heimdal.trondhjem.org>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu>
	 <1240519320.5602.9.camel@heimdal.trondhjem.org>
	 <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
	 <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
	 <1240577989.32585.1.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de,  linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1240577989.32585.1.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-04-24 at 08:59 -0400, Chris Mason wrote:
> On Fri, 2009-04-24 at 09:33 +0200, Miklos Szeredi wrote:
> > On Fri, 24 Apr 2009, Miklos Szeredi wrote:
> > > Hmm, I guess this is a bit nasty: the VM promises filesystems that
> > > ->page_mkwrite() will be called when the page is dirtied through a
> > > mapping, _almost_ all of the time.  Except when munmap happens to race
> > > with clear_page_dirty_for_io().
> > > 
> > > I don't have any ideas how this could be fixed, CC-ing linux-mm...
> > 
> > On second thought, we could possibly just ignore the dirty bit in that
> > case.  Trying to write to a mapping _during_ munmap() will have pretty
> > undefined results, I don't think any sane application out there should
> > rely on the results of this.
> > 
> > But how knows, the world is a weird place...
> 
> It does happen in practice, btrfs has fallback code that triggers the
> page_mkwrite when it finds a dirty page that wasn't dirtied with help
> from the FS.
> 
> I'd love to get rid of the fallback ;)

So is there any reason why we shouldn't put calls to page_mkwrite in
zap_pte_range?

The only alternative I can think of would be to unmap the page when the
filesystem starts to write it out in order to force another page fault
if the user application writes more data into that page.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
