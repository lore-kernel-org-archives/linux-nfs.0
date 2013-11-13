Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943Ab3KMEP1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 23:15:27 -0500
Message-ID: <5282FCD0.6030307@redhat.com>
Date: Tue, 12 Nov 2013 23:15:12 -0500
From: "Carlos O'Donell" <carlos@redhat.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>, viro@ZenIV.linux.org.uk
CC: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        libc-alpha@sourceware.org, linux-api@vger.kernel.org,
        andreas.gruenbacher@gmail.com, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/3] Extended file stat system call [ver #2]
References: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
In-Reply-To: <20131112184127.2880.24025.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2013 01:41 PM, David Howells wrote:
> 
> Implement a new system call to provide an extended and further extensible stat
> function.
> 
> =======
> CHANGES
> =======
> 
>  (*) Added an optional auxiliary data buffer pointer argument to sys_statxat()
>      and moved some of the stuff into it.
> 
>  (*) Discarded "has an ACL info flag" for now.
> 
>  (*) AFS doesn't need to set time granularity itself as the default is 1s
>      anyway.

David,

This looks like great work. I admire the thoroughness and
the detail of the patches. I don't have much more to say
other than it looks robust and very well put together.

You have CC'd the glibc development list on these changes
and I appreciate that as a heads up on new syscalls is very
very useful for the developers.

Do you have any other expectations from the glibc development
community? Are you looking for help wiring this up or will
you be posting glibc patches at a later date?

Cheers,
Carlos.
