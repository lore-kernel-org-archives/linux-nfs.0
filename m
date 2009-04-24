From: Chris Mason <chris.mason@oracle.com>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Fri, 24 Apr 2009 08:59:49 -0400
Message-ID: <1240577989.32585.1.camel@think.oraclecorp.com>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu>
	 <1240519320.5602.9.camel@heimdal.trondhjem.org>
	 <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
	 <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: trond.myklebust@fys.uio.no, npiggin@suse.de,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-04-24 at 09:33 +0200, Miklos Szeredi wrote:
> On Fri, 24 Apr 2009, Miklos Szeredi wrote:
> > Hmm, I guess this is a bit nasty: the VM promises filesystems that
> > ->page_mkwrite() will be called when the page is dirtied through a
> > mapping, _almost_ all of the time.  Except when munmap happens to race
> > with clear_page_dirty_for_io().
> > 
> > I don't have any ideas how this could be fixed, CC-ing linux-mm...
> 
> On second thought, we could possibly just ignore the dirty bit in that
> case.  Trying to write to a mapping _during_ munmap() will have pretty
> undefined results, I don't think any sane application out there should
> rely on the results of this.
> 
> But how knows, the world is a weird place...

It does happen in practice, btrfs has fallback code that triggers the
page_mkwrite when it finds a dirty page that wasn't dirtied with help
from the FS.

I'd love to get rid of the fallback ;)

-chris


