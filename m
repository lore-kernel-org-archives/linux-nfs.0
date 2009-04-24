From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Fri, 24 Apr 2009 09:33:05 +0200
Message-ID: <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
Cc: miklos@szeredi.hu, npiggin@suse.de, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:38026 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZDXHdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 03:33:18 -0400
In-reply-to: <E1LxFd4-0008Ih-Rd-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org> (message from Miklos
	Szeredi on Fri, 24 Apr 2009 09:15:22 +0200)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Apr 2009, Miklos Szeredi wrote:
> Hmm, I guess this is a bit nasty: the VM promises filesystems that
> ->page_mkwrite() will be called when the page is dirtied through a
> mapping, _almost_ all of the time.  Except when munmap happens to race
> with clear_page_dirty_for_io().
> 
> I don't have any ideas how this could be fixed, CC-ing linux-mm...

On second thought, we could possibly just ignore the dirty bit in that
case.  Trying to write to a mapping _during_ munmap() will have pretty
undefined results, I don't think any sane application out there should
rely on the results of this.

But how knows, the world is a weird place...

Miklos
