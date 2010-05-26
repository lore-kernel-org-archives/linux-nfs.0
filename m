From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfs_access_cache_shrinker() is missing an unlock
Date: Wed, 26 May 2010 08:34:33 -0400
Message-ID: <1274877273.5270.6.camel@heimdal.trondhjem.org>
References: <2068.1274876574@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568Ab0EZMef convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 08:34:35 -0400
In-Reply-To: <2068.1274876574@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-05-26 at 13:22 +0100, David Howells wrote: 
> Hi Trond,
> 
> nfs_access_cache_shrinker() incurs the attached lockdep warning and then locks
> up.
> 
> Specifically, the problem appears to be the:
> 
> 		spin_lock(&inode->i_lock);
> 
> in the loop, for which there's not an unlock.  Nor is there an unlock in
> nfs_access_free_list() or nfs_access_free_entry.
> 
> Is the spin_unlock() supposed to occur at the end of the loop, just before the
> closing brace?  Or did you mean to defer the unlock to nfs_access_free_entry()?

Oh, crap... That's a typo in commit
9c7e7e23371e629dbb3b341610a418cdf1c19d91. I did not intend to remove the
spin_unlock(&inode->i_lock) line.

Thanks for spotting that!

Trond
