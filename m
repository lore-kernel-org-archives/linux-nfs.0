Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37696 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933659Ab1JaS2h convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 14:28:37 -0400
Subject: Re: [PATCH] nfs: Fix unused variable warning.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org
Date: Mon, 31 Oct 2011 14:28:36 -0400
In-Reply-To: <CADZ9YHgR=WHzCfJf7_T_WjHJJHzOnWZsM2bWSACwLHEcHy+h-g@mail.gmail.com>
References: <1319798192.26450.1.camel@localhost.localdomain>
	 <1320074323.4714.2.camel@lade.trondhjem.org>
	 <CADZ9YHhq91+Td03OjWbX0rwHwb6Y7QhicsuDqqAUSy2O8=05BA@mail.gmail.com>
	 <1320083034.4714.24.camel@lade.trondhjem.org>
	 <CADZ9YHgR=WHzCfJf7_T_WjHJJHzOnWZsM2bWSACwLHEcHy+h-g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320085716.4714.52.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-01 at 00:16 +0600, Rakib Mullick wrote: 
> On Mon, Oct 31, 2011 at 11:43 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2011-10-31 at 23:12 +0600, Rakib Mullick wrote:
> >> On Mon, Oct 31, 2011 at 9:18 PM, Trond Myklebust
> >> <Trond.Myklebust@netapp.com> wrote:
> >> > On Fri, 2011-10-28 at 16:36 +0600, Rakib Mullick wrote:
> >> +                             data->inode->nfs_client->cl_hostname,
> >                                 ^^^^^^^^^^^^
> > NFS_SERVER(data->inode)->nfs_client....
> 
> Opss. Sorry, should've more careful, rather doing it quickly :(.
> data->inode has nothing inside named nfs_client, but didn't even
> complain. I'll resend it.
> 
> Anyway, I found the two following warning in nfs/file.c
> 
> fs/nfs/file.c: In function ‘nfs_file_release’:
> fs/nfs/file.c:140:17: warning: unused variable ‘dentry’
> fs/nfs/file.c: In function ‘nfs_file_read’:
> fs/nfs/file.c:237:9: warning: unused variable ‘count’
> 
> I'm wanting to send one patch to cleanup all these unused variable
> issues. Shall I? Or, should I send separate patches?

Please send 2 patches: the stuff in fs/nfs/file.c looks as if it
predates the linux-3.1 release, and so we might want to keep those fixes
in a separate patch.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

