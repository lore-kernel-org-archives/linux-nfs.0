From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Many open/close on same files yeilds "No such file or
	directory".
Date: Mon, 12 May 2008 02:00:15 -0400
Message-ID: <20080512060015.GB31262@fieldses.org>
References: <4819E316.7000607@krogh.cc> <4823DFA6.9010504@krogh.cc> <20080508223635.523b8fa7.akpm@linux-foundation.org> <4823EA9E.6050703@krogh.cc> <18471.41781.164396.385159@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbYELGAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2008 02:00:20 -0400
In-Reply-To: <18471.41781.164396.385159-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2008 at 11:53:57AM +1000, Neil Brown wrote:
> On Friday May 9, jesper-Q2TZfHgGEy4@public.gmane.org wrote:
> > 
> > When I disabled the NFS-server and rand my "real-world" program on a
> > single processor (make -j 1). It ran through fine. It basically
> > gets around 20 million chunks out of differnet file and assemble the
> > chuncks in a few other files. This processes more or less 5 individual
> > sections, so make can run effectively with a concurrency of 5.
> 
> (For linux-nfs readers: the problem is that repeatedly opening a given
>  file sometimes returns a ENOENT - http://lkml.org/lkml/2008/5/9/15).
> 
> The mention of an NFS-server made my ears prick up...
> 
> Do I understand correctly that the problem only occurs when you have
> 48 clients hammering away at the filesystem in question?
> 
> Could the clients be accessing the same file that you are experiencing
> problems with?  Or one of the directories in the path (if so, how
> deep).
> 
> How many different files to these 20 million chunks come from?  And
> how does that number compare with the first number from
>    grep dentry /proc/slabinfo
> ??
> 
> The NFS server does some slighty strange things with the dcache if the
> object being access is not in the cache.
> 
> Also, can get a few instances of 
>    grep '^fh' /proc/nfs/rpc/nfsd

I think you meant /proc/net/rpc/nfsd.

--b.

> 
> while things are going strange.  The numbers are:
>  *	fh <stale> <total-lookups> <anonlookups> <dir-not-in-dcache> <nondir-not-in-dcache>
> 
> That will show us if it is looking for things that aren't in the
> dcache.
> 
> Finally, if the filesystem export with "subtree_check" or
> "nosubtree_check"?
> Does it make a difference if you switch the setting of this flag and
> re-export?
> 
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
