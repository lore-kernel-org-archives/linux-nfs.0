Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f176.google.com ([209.85.215.176]:64219 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3JMG0h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 02:26:37 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so2698426ead.35
        for <linux-nfs@vger.kernel.org>; Sat, 12 Oct 2013 23:26:36 -0700 (PDT)
Message-ID: <525A3D19.9000004@primarydata.com>
Date: Sun, 13 Oct 2013 09:26:33 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
References: <52447EA0.7070004@primarydata.com> <1380220968-14669-1-git-send-email-bhalevy@primarydata.com> <20131011194746.GB4941@infradead.org>
In-Reply-To: <20131011194746.GB4941@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-11 22:47, Christoph Hellwig wrote:
> I've been looking at this patch and the surrounding code a bit more and
> start to really dislike it.
> 
> put_nfs4_file is very much unrelated to the state lock, so having a
> version that internally drops it seems wrong.  If we look at the usage
> of your new locked version there's very few callers:
> 
> 
>  put_nfs4_file_locked
>   + destroy_layout_state
>      + put_layout_state
>         + destroy_layout
> 	  + destroy_layout_list
> 	     + nfs4_pnfs_return_layout
> 	     + pnfs_expire_client
> 	+ nfs4_pnfs_get_layout
> 	+ nfs4_pnfs_return_layout
> 
> Except for pnfs_expire_client all these are right near the places where
> the state lock is dropped, so simply refactoring the code sounds like
> a very valid option.

I hear you.  Makes sense.

> 
> 
> And btw, the state locking is even more of a mess than I though.  I
> think it really needs to be split up sooner or later.
> 

I'm working on patches eliminating the state lock by refactoring the code
that is currently protected by it, moving all blocking calls to either before
or after the critical section.  I'll send a RFC patchset as soon as I have
the first stab at it completed.

Benny
