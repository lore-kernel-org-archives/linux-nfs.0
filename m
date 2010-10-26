Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55118 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755211Ab0JZUgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 16:36:07 -0400
Message-ID: <4CC73BA6.1090407@netapp.com>
Date: Tue, 26 Oct 2010 16:35:50 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Arnd Bergmann <arnd@arndb.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
References: <20101026164549.GD19445@fieldses.org> <201010262218.36940.arnd@arndb.de>
In-Reply-To: <201010262218.36940.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

I left the one call because I was unable to figure out what was being protected with the BKL in that section of the code.  I figured I would leave it for the maintainers, since they know more about the code than I do.

Bryan

On 10/26/2010 04:18 PM, Arnd Bergmann wrote:
> On Tuesday 26 October 2010 18:45:50 J. Bruce Fields wrote:
>> Bryan Schumaker (1):
>>       lockd: Mostly remove BKL from the server
> 
> Could you explain the "mostly" part of this commit?
> 
> The commit message only says "This patch removes all
> but one call to lock_kernel() from the server." This one
> call is what keeps us from removing the BKL from fs/locks.c
> because I can't tell if you still suspect that lockd
> needs to lock against posix file locks or if there was
> a different reason for leaving it in.
> 
> I can't think of anything else that this might be locking
> against because everything that might interact with lockd
> now does not use the BKL any more and lockd is
> single-threaded by definition.
> 
> My guess is that the only thing that really needs to
> lock_flocks() in lockd are the nlm_file_inuse and
> nlm_traverse_locks functions because they traverse
> the inode->i_flock list. All the exported functions
> from fs/lock.c take care of locking in their own way
> (possibly not lease_get_time, as I just discovered,
> but that was never called under the BKL...).
> 
> 	Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

