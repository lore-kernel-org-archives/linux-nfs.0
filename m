Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60833 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab2CBFIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 00:08:23 -0500
Date: Thu, 1 Mar 2012 23:08:13 -0600
From: Jonathan Nieder <jrnieder@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>,
        Rik Theys <Rik.Theys@esat.kuleuven.be>,
        David Flyn <davidf@rd.bbc.co.uk>
Subject: Re: [PATCH v2] NFSv4: Save the owner/group name string when doing
 open
Message-ID: <20120302050813.GA32761@burratino>
References: <1325956115-21767-1-git-send-email-Trond.Myklebust@netapp.com>
 <1325960863-31742-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1325960863-31742-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Trond Myklebust wrote:

> [Subject: NFSv4: Save the owner/group name string when doing open]
>
> ...so that we can do the uid/gid mapping outside the asynchronous RPC
> context.
> This fixes a bug in the current NFSv4 atomic open code where the client
> isn't able to determine what the true uid/gid fields of the file are,
> (because the asynchronous nature of the OPEN call denies it the ability
> to do an upcall) and so fills them with default values, marking the
> inode as needing revalidation.
> Unfortunately, in some cases, the VFS will do some additional sanity
> checks on the file, and may override the server's decision to allow
> the open because it sees the wrong owner/group fields.

Thanks!  This patch (commit 6926afd1925a, 2012-01-07) fixes the
following client-side bug[1]:

| Our home directories here are mounted over NFS4. When I log in to machine A
| and run
|
| vim
| :q
|
| and then log into machine B and do:
|
| vim
| :q
|
| I get E137: Viminfo file is not writable: /users/system/rtheys/.viminfo
|
| Every invocation of 'vim and :q' will trigger this.
|
| Explicitely doing a stat of the file fixes this.

Rik Theys bisected and found the bug reproducible after and not before
v2.6.32-rc1~412^2~48^2~15 (NFSv4: Don't do idmapper upcalls for
asynchronous RPC calls, 2009-08-09).

[...]
>  6 files changed, 162 insertions(+), 64 deletions(-)

Now I am wondering what, if anything, can be done to fix this in the
2.6.32.y, 3.0.y, and 3.2.y stable kernels.  The patch looks too big
for inclusion under the usual stable_kernel_rules:

 - It cannot be bigger than 100 lines, with context.

Ideas?
Jonathan

[1] http://bugs.debian.org/659111
    http://thread.gmane.org/gmane.linux.nfs/37230
