Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756893Ab2DZSde (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 14:33:34 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3QIXWIw003753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 14:33:34 -0400
Message-ID: <4F9987FE.3040605@RedHat.com>
Date: Thu, 26 Apr 2012 13:38:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 0/9] nfsdcld: add a daemon to track NFSv4 client names
 on stable storage
References: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/01/2012 10:44 AM, Jeff Layton wrote:
> This patchset is the userspace portion of the knfsd client name tracking
> overhaul. See this patch series for an explanation:
> 
>     nfsd: overhaul the client name tracking code
> 
> This version scales back some of the changes in the last set. Since
> then, it's become clear that I'm not entirely certain what changes we'll
> need in order to handle this in a clustered configuration. Instead of
> trying to anticipate those changes, I've decided just to focus on the
> single-server case and leave any other changes for later once it becomes
> more clear what (if anything) is needed.
> 
> The main changes from the last set are:
> 
> - the "remove" upcall has been readded
> 
> - the "init" upcall has been removed
> 
> - the "check" and "update" upcalls no longer return a client index
>   to the kernel
> 
> - the pipe open and reopen code has been overhauled and consolidated.
>   Instead of looping indefinitely when trying to reopen the file, it will
>   abort the daemon if the open fails with anything besides ENOENT. If
>   the pipe isn't present when the daemon starts, it now uses the inotify
>   event callback to handle the opening.
> 
> Jeff Layton (9):
>   nfsdcld: add client tracking daemon stub
>   nfsdcld: add autoconf goop for sqlite
>   nfsdcld: add routines for a sqlite backend database
>   nfsdcld: add remove functionality
>   nfsdcld: add check/update functionality
>   nfsdcld: add function to remove unreclaimed client records
>   nfsdcld: make it watch for inotify events in the containing directory
>   nfsdcld: add a manpage for nfsdcld
>   nfsdcld: update the README
Committed.... My apologies for taking so long... 

steved.
