From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] Please pull the first batch of NFS client changes
 (and cachefs merge)...
Date: Wed, 1 Apr 2009 09:43:13 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904010935000.4130@localhost.localdomain>
References: <1238522824.6577.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	dhowells@redhat.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48203 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756723AbZDAQrE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 12:47:04 -0400
In-Reply-To: <1238522824.6577.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 31 Mar 2009, Trond Myklebust wrote:
> 
> Please pull from the "for-linus" branch of the repository at
> 
>    git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git for-linus

I _really_ want fscache to come with way more Acked-by's etc. 

So no, I'm not going to pull this. I want a lot more than just

	Signed-off-by: David Howells <dhowells@redhat.com>

on the 100+ lines of changes to the VM. I want the VM people pinged and 
asked whether it's ok.

And I also have a stupid trivial complaint:

WTF is up with absolutely inane crap like this:

>  fs/cachefiles/cf-bind.c                           |  286 +++++++
>  fs/cachefiles/cf-daemon.c                         |  754 ++++++++++++++++++
>  fs/cachefiles/cf-interface.c                      |  449 +++++++++++
>  fs/cachefiles/cf-internal.h                       |  360 +++++++++
>  fs/cachefiles/cf-key.c                            |  159 ++++
>  fs/cachefiles/cf-main.c                           |  106 +++
>  fs/cachefiles/cf-namei.c                          |  772 +++++++++++++++++++
>  fs/cachefiles/cf-proc.c                           |  134 ++++
>  fs/cachefiles/cf-rdwr.c                           |  853 +++++++++++++++++++++
>  fs/cachefiles/cf-security.c                       |  116 +++
>  fs/cachefiles/cf-xattr.c                          |  291 +++++++
...
>  fs/fscache/fsc-cache.c                            |  415 ++++++++++
>  fs/fscache/fsc-cookie.c                           |  498 ++++++++++++
>  fs/fscache/fsc-fsdef.c                            |  144 ++++
>  fs/fscache/fsc-histogram.c                        |  109 +++
>  fs/fscache/fsc-internal.h                         |  380 +++++++++
>  fs/fscache/fsc-main.c                             |  124 +++
>  fs/fscache/fsc-netfs.c                            |  103 +++
>  fs/fscache/fsc-object.c                           |  810 +++++++++++++++++++
>  fs/fscache/fsc-operation.c                        |  459 +++++++++++
>  fs/fscache/fsc-page.c                             |  771 +++++++++++++++++++
>  fs/fscache/fsc-proc.c                             |   68 ++
>  fs/fscache/fsc-stats.c                            |  212 +++++

What the hell is that "cf-" and "fsc-" prefix? We don't do single-level 
naming crud. It's already in a directory hierarchy, why the _hell_ does it 
then add some idiotic extra prefix that is just a (very inferior) copy of 
that hierarchy?

If you want to write "fscache", write it out. Don't do "fsc". And do it as 
a directory. But then even an idiot would see that calling it 
fs/fscache/fscache/proc.c is a bit redundant. So why do you call it 
fs/fscache/fsc-proc.c?

Gaah. Naming is a bid deal for me, and the above is just crap.

			Linus
