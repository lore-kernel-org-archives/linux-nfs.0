Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:42105 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaIEJVJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 05:21:09 -0400
Date: Fri, 5 Sep 2014 10:21:05 +0100
From: Luis Henriques <luis.henriques@canonical.com>
To: NeilBrown <neilb@suse.de>
Cc: stable@vger.kernel.org, NFS <linux-nfs@vger.kernel.org>,
        Lars Behrens <lars.behrens@pi.uka.de>, Willy Tarreau <w@1wt.eu>
Subject: Re: Incorrect backport to 2.6.32-stable - NFSD regression.
Message-ID: <20140905092105.GA6614@hercules>
References: <20140903112843.66bcd6dd@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20140903112843.66bcd6dd@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Adding Willy to the CC list, in case he misses this email.)

On Wed, Sep 03, 2014 at 11:28:43AM +1000, NeilBrown wrote:
> 
> 2.6.32.30 contains:
> 
> commit 63d059e73ff4574b79bd8aa252b5fc00b6326ddf
> Author: NeilBrown <neilb@suse.de>
> Date:   Wed Feb 16 13:08:35 2011 +1100
> 
>     nfsd: correctly handle return value from nfsd_map_name_to_*
>     
>     commit 47c85291d3dd1a51501555000b90f8e281a0458e upstream.
>     
>     These functions return an nfs status, not a host_err.  So don't
>     try to convert  before returning.
>     
>     This is a regression introduced by
>     3c726023402a2f3b28f49b9d90ebf9e71151157d; I fixed up two of the callers,
>     but missed these two.
>     
>     Reported-by: Herbert Poetzl <herbert@13thfloor.at>
>     Signed-off-by: NeilBrown <neilb@suse.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> 
> But it does *not* contain a backport of
> 3c726023402a2f3b28f49b9d90ebf9e71151157d.
> 
> So rather an fixing a regression, it introduces one.
> 
> This patch should be reverted.
> 
> See also https://bugzilla.novell.com/show_bug.cgi?id=893787
> 
> NeilBrown

Thanks a lot for reporting this here, Neil.  I'll make sure we revert
it from the Ubuntu 10.04 LTS kernel.

Cheers,
--
Luís
