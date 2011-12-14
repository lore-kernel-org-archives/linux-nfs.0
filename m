Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757112Ab1LNPXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 10:23:16 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEFNGeJ007867
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 10:23:16 -0500
Message-ID: <4EE8BF63.6080906@RedHat.com>
Date: Wed, 14 Dec 2011 10:23:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] clstated: add a daemon to track NFSv4 client names
 on stable storage (RFC)
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2011 08:57 AM, Jeff Layton wrote:
> This patchset is the userspace portion of the knfsd client name tracking
> overhaul. See this patch series for an explanation:
> 
>     nfsd: overhaul the client name tracking code (RFC)
> 
> The daemon listens for upcalls on the rpc_pipefs pipe using libevent,
> and handles the requests.
> 
> The data is stored using a sqlite database. The main reason for this is
> that it takes care of most of the fussy details and atomicity concerns
> of tracking the information on stable storage.
This will make nfs-utils dependent on the sqlite database... Any idea
what kinda of extra baggage this brings? 

> 
> For now, the daemon is only suitable for single-host configurations.
> The plan is to later extend this to be suitable for clustered
> configurations as well.
> 
> The code is still a little rough, so be gentle. It also lacks things
> like a manpage. I plan to add all that before doing a "formal" patch
> submission, but I wanted to get some early review of the overall design
> before to spend a lot of time knocking off the rough edges.
Finally the name of the daemon...  clstated does not make it clear that 
this is a nfs server daemon... maybe something like nfsdcld? 

steved.

> 
> Jeff Layton (7):
>   clstated: add clname tracking daemon stub
>   clstated: reattempt the pipe open if it fails on ENOENT
>   clstated: add autoconf goop for sqlite
>   clstated: add routines for a sqlite backend database
>   clstated: add remove functionality
>   clstated: add check/update functionality
>   clstated: add function to remove unreclaimed client records
> 
>  aclocal/libsqlite3.m4      |   33 +++
>  configure.ac               |   23 ++
>  utils/Makefile.am          |    4 +
>  utils/clstated/Makefile.am |   14 +
>  utils/clstated/clstated.c  |  355 +++++++++++++++++++++++++++
>  utils/clstated/sqlite.c    |  572 ++++++++++++++++++++++++++++++++++++++++++++
>  utils/clstated/sqlite.h    |   30 +++
>  7 files changed, 1031 insertions(+), 0 deletions(-)
>  create mode 100644 aclocal/libsqlite3.m4
>  create mode 100644 utils/clstated/Makefile.am
>  create mode 100644 utils/clstated/clstated.c
>  create mode 100644 utils/clstated/sqlite.c
>  create mode 100644 utils/clstated/sqlite.h
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
