Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24407 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949AbaHLSWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 14:22:03 -0400
Message-ID: <53EA5B47.7020306@RedHat.com>
Date: Tue, 12 Aug 2014 14:21:59 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Pavel Shilovsky <pshilovsky@samba.org>
CC: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>
Subject: Re: [PATCH 0/5] SMB/CIFS nounix support for Connectathon test suite
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/06/2014 08:01 AM, Pavel Shilovsky wrote:
> The goal of the series is to add support of testing various versions of SMB/CIFS protocol without Unix extensions. Also there are two patches that fixes problems in special and tlock tests.
> 
> With the patchset applied nounix SMB/CIFS servers and clients can be tested with "server -C" command.
> 
> Jeff Layton (2):
>   tlock: munmap missed before close
>   Add SMB/CIFS mounts support
> 
> Pavel Shilovsky (3):
>   Add capability to test SMB 2.0 and higher verions
>   Add SMB/CIFS section in tests.init
>   special: fix op_unlk and op_ren tests output
> 
>  basic/runtests       |  8 +++++---
>  lock/runtests        |  9 +++++++--
>  lock/tlock.c         | 11 +++++++++--
>  server               |  5 +++--
>  special/op_ren.c     | 16 +++++++++++++---
>  special/op_unlk.c    |  8 +++++---
>  special/runtests.wrk | 11 ++++++++---
>  tests.init           |  4 ++++
>  8 files changed, 54 insertions(+), 18 deletions(-)
> 
All five patches have been committed... 

steved.
