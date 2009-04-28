From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 19/19] lockd: clean up 64-bit alignment fix in
	nsm_init_private()
Date: Tue, 28 Apr 2009 18:23:41 -0400
Message-ID: <20090428222341.GP23924@fieldses.org>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233340.17283.29580.stgit@ingres.1015granger.net> <20090428163101.GK17891@fieldses.org> <1AF02847-8D16-4387-81CB-F36969CA9883@oracle.com> <20090428164027.GO17891@fieldses.org> <9A6CA37F-0D4D-48C3-AEF8-E47B2836EDCC@oracle.com> <20090428213638.GL23924@fieldses.org> <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:43975 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZD1WXl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 18:23:41 -0400
In-Reply-To: <CAA58A55-4ED9-4D45-BE54-66DD8CEF191C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 06:11:06PM -0400, Chuck Lever wrote:
> This patch is simply a clean up.  We don't need to use put_unaligned in 
> nsm_init_private.  There is absolutely nothing special about the  
> nsm_private data type that would require this.  It should be accessed  
> and modified the way all other RPC opaques are, via memset/memcpy.
>
> Take a look at http://thread.gmane.org/gmane.linux.nfs/25607 and commit 
> ad5b365c.
>
> The controversy is over how to define opaques so they are accessible on 
> both 32- and 64-bit hardware platforms.  My first pass at  
> nsm_init_private worked on 32-bit systems, but broke on 64-bit systems.  
> An expedient fix for this was to add the put_unaligned in there so 64-bit 
> systems could access the field no matter how it was aligned.  I argue 
> this is unneeded complexity, and inconsistent with the way most other RPC 
> opaques are treated in the kernel.
>
> Andrew Morton proposed making RPC opaques a union of u8, u32 (or  
> __be32), and u64 -- the u8 would allow us to treat an opaque as a byte  
> array when needed, the u32 would allow access via XDR quads, and the u64 
> would force 64-bit alignment.  The issues with this are:
>
> 1.  Defined this way, opaque fields in data structures will force the  
> encompassing structures to be large enough to honor the alignment  
> requirements of the fields, and
>
> 2.  Most other RPC opaques are already defined as character arrays, so  
> we would have to visit all of them to see if there were issues.
>
> If we insist on accessing opaques only via memset() and memcpy() problem 
> 1 goes away and we remain compatible with the traditional definition of 
> an RPC opaque as an array of bytes, on both 64- and 32-bit systems.
>
> The description for this patch can be rewritten this way:
>
> "Clean up: There is nothing special about the nsm_private data type that 
> requires the use of put_unaligned() to access it.  Rewrite  
> nsm_init_private so it accesses nsm_private the way other code accesses 
> other RPC opaques.
>
> See kernel bugzilla 12995."

OK.--b.
