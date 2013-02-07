Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37055 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758867Ab3BGROB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 12:14:01 -0500
Date: Thu, 7 Feb 2013 12:14:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Refactor nfsd4_do_encode_secinfo()
Message-ID: <20130207171400.GO3222@fieldses.org>
References: <20130201220308.13518.82164.stgit@seurat.1015granger.net>
 <20130207150213.GC3222@fieldses.org>
 <87316F41-4E5E-473C-A372-0AFC6721A355@oracle.com>
 <20130207162308.GI3222@fieldses.org>
 <F0DAA0C6-DBA2-457B-8C68-13A2BC3CB4AC@oracle.com>
 <20130207165509.GM3222@fieldses.org>
 <436D6F2C-E520-4375-A518-2E55031E70F7@oracle.com>
 <A98AFAD6-2E43-4646-8287-8C023DFA65DF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A98AFAD6-2E43-4646-8287-8C023DFA65DF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 12:12:24PM -0500, Chuck Lever wrote:
> 
> On Feb 7, 2013, at 12:03 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > I've thought a little about that.  There is already a logged warning if a gssd upcall times out.  But it's hard to tell inside the kernel why a module doesn't load.  These all look pretty much the same to the RPC layer:
> > 
> >   -  module is blacklisted or not installed?
> >   -  GSS support wasn't built?
> >   -  filesystem corruption?
> >   -  export specifies a security flavor the RPC client doesn't recognize?
> > 
> > I suppose I could add something here, but I wonder about the false alarms.
> 
> How about this:
> 
>   "Warning: export specifies a security flavor that isn't supported"

Sounds fine.  With a guard so we just say it once.

Bonus if we could say which export or which flavor?

--b.
