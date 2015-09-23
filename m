Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755109AbbIWVTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2015 17:19:51 -0400
Subject: Re: [PATCH Version 2 0/4] GSSD: Do not fork when UID = 0
To: andros@netapp.com
References: <1443018616-1335-1-git-send-email-andros@netapp.com>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56031775.8010304@RedHat.com>
Date: Wed, 23 Sep 2015 17:19:49 -0400
MIME-Version: 1.0
In-Reply-To: <1443018616-1335-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/23/2015 10:30 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Version 2:
> responded to comments.
> - removed some printerr from 0003
> - removed the SIGKILL call from 0004
> 
> Version 1:
> Jeff Layton worked on this patch set with me.
> 
> patch 0001 and 0002 clean up process_krb5_upcall() by moving the two cases into
> helper functions.
> 
> patch 0003 is the heart of this patch set.
> 
> commit f9cac65972da588d5218236de60a7be11247a8aa added the fork to
> process_krb5_upcall so that the child assumes the uid of the principal
> requesting service. This is good for the reasons listed in the commit.
> 
> When machine credentials are used, a gssd_k5_kt_princ entry is added to
> a global list and used by future upcalls to note when valid machine credentials
> have been obtained. When a child process performs this task, the entry to the
> global list is lost upon exit, and all upcalls for machine credentials re-fetch
> a TGT, even when a valid TGT is in the machine kerberos credential cache.
> 
> Since forking is not necessary when the principal has uid=0, solve the
> gssd_k5_kt_princ_list issue by only forking when the uid != 0.
> 
> Please do more testing. Comments welcome.
> 
> -->Andy
> 
> Andy Adamson (4):
>   GSSD: move process_krb5_upcall machine cred case to helper function
>   GSSD: move process_krb5_updcall non machine cred case to helper
>     function
>   GSSD only fork when uid is not zeo
>   GSSD: clean up machine credentials
Committed all four of them... with some minor changes
in the debug statements and bug fixed in the third one... 

steved.

> 
>  utils/gssd/gssd.c      |  11 ++-
>  utils/gssd/gssd_proc.c | 239 ++++++++++++++++++++++++++++++-------------------
>  2 files changed, 150 insertions(+), 100 deletions(-)
> 
