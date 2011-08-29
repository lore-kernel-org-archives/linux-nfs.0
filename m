Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955Ab1H2Rs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 13:48:29 -0400
Message-ID: <4E5BD0EA.10802@RedHat.com>
Date: Mon, 29 Aug 2011 13:48:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Possible fixes for statd / sm-notify / exportfs
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/24/2011 11:33 AM, Chuck Lever wrote:
> While working on another fix, I noticed that the complex hostname
> matching logic in statd, exportfs, and sm-notify appears to break with
> the local hostname and IP addresses.  I propose the following to
> address this.
> 
> ---
> 
> Chuck Lever (5):
>       sm-notify: sm-notify doesn't handle localhost properly
>       exportfs: matchhostname() doesn't handle localhost properly
>       statd: statd_matchhostname() doesn't handle localhost properly
>       sm-notify: Disable syslog messages when debugging is enabled
>       statd: Report count of loaded hosts correctly
> 
> 
>  utils/exportfs/exportfs.c |   34 +++++++++++-
>  utils/statd/hostname.c    |   55 ++++++++++++++++---
>  utils/statd/monitor.c     |    2 -
>  utils/statd/sm-notify.c   |  133 ++++++++++++++++++++++++++++++++++++---------
>  4 files changed, 186 insertions(+), 38 deletions(-)
> 
All 5 patches committed...

steved.
