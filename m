From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Thu, 23 Apr 2009 21:52:46 +0200
Message-ID: <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
Cc: npiggin@suse.de, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:55742 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbZDWTw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 15:52:56 -0400
In-reply-to: <1240510668.11148.40.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (message from
	Trond Myklebust on Thu, 23 Apr 2009 14:17:48 -0400)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 23 Apr 2009, Trond Myklebust wrote:
> I'm still working on the bug in
> http://bugzilla.kernel.org/show_bug.cgi?id=12913 . One other source of
> grief appears to be munmap(), which is calling set_page_dirty() on a
> number of pages without locking them or first calling page_mkwrite(). 
> 
> Currently, this means that we either ignore that dirty bit (since
> nfs_page_async_flush() won't find a corresponding write request) or it
> too can end up triggering the PG_CLEAN BUG() in fs/nfs/write.c:252 if
> the timing is right.
> 
> So what is the reason why zap_pte_range() calls set_page_dirty()
> directly?

In the old times this was one of the main ways of transferring the pte
dirtyness to the PG_dirty page flag.

Now this is mostly done at page fault time, and the pte's are always
being re-protected whenever the PG_dirty flag is cleared (see
page_mkclean()).

But in some cases (shmfs being the example I know) pages are not write
protected and so zap_pte_range(), and other functions, still need to
transfer the pte dirtyness to the page flag.

Not sure how this matters to NFS though.  If the above is correct,
then the set_page_dirty() call in zap_pte_range() should always result
in a no-op, since the PG_dirty flag would already have been set by the
page fault...

Miklos
