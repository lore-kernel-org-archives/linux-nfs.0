Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482Ab1F0QXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 12:23:32 -0400
Message-ID: <4E08AE80.8030505@RedHat.com>
Date: Mon, 27 Jun 2011 12:23:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Tom Haynes <loghyr@gmail.com>
CC: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: Re: [PATCH 0/2] minor patches to cthon tests for FreeBSD
References: <1308795967-7605-1-git-send-email-tdh@excfb.com>
In-Reply-To: <1308795967-7605-1-git-send-email-tdh@excfb.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/22/2011 10:26 PM, Tom Haynes wrote:
> First allows FreeBSD 9.0 to compile and second allows
> for leading space in the time output.
> 
> Tom Haynes (2):
>   Multiple clnt_broadcast, rename static reference
>   Make the stat command handle leading blank spaces
> 
>  general/stat.c  |    4 +++-
>  tools/pmapbrd.c |    7 ++++---
>  2 files changed, 7 insertions(+), 4 deletions(-)
> 
Both committed on the git://linux-nfs.org/~steved/exports/cthon04 tree

steved.
