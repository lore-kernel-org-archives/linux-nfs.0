Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39179 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab1LAT47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 14:56:59 -0500
Message-ID: <4ED7DBF9.7050404@netapp.com>
Date: Thu, 01 Dec 2011 14:56:41 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com> <20111201173642.GB11436@umich.edu>
In-Reply-To: <20111201173642.GB11436@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu Dec  1 12:36:42 2011, Jim Rees wrote:
> bjschuma@netapp.com wrote:
>
>   From: Bryan Schumaker <bjschuma@netapp.com>
>   
>   This set of patches removes NFS v3 from the main NFS kernel module and creates
>   a new module containing the proc, xdr, and acl code.  This will give us a
>   single directory to put NFS v3 specific code so it doesn't need to be mixed in
>   with the generic client stuff.
>
> Thanks!  Is v4 next?  This will come in handy when we implement v5.

I wonder if there would be a sane way of creating modules for minor 
versions of v4 rather than waiting for v5?
>
> But seriously...  If we take this to its logical conclusion, won't we need a
> subdirectory for nfs4?  And if we do that, will block and object layout be
> subdirectories of nfs, or of v4?

Yeah, there would be a v4 subdirectory.  I would expect that they would 
be moved to subdirectories of v4, since they shouldn't be needed for 
generic NFS, v2 or v3.
>
> And while we're at it, should file layout move to a subdir like block and
> object?

That would make sense to me.  It would be more consistent with what the 
other layout modules are doing.

>
> And what about v2?  There's only nfs2xdr.c, so a subdir seems like overkill.

v2 also has proc.c, it's just not named "nfs2proc.c".  Right now, 
turning on CONFIG_NFS_FS will always turn on v2, so unless this is 
changed it won't need a separate subdirectory.  Another thought: would 
there be any benefit to splitting nfs*proc.c and/or nfs*xdr.c into 
multiple files?


