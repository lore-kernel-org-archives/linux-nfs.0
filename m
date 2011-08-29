Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753872Ab1H2QFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 12:05:07 -0400
Message-ID: <4E5BB8B0.30101@RedHat.com>
Date: Mon, 29 Aug 2011 12:05:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Luk Claes <luk@debian.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] start-statd: Use bash as -p is no POSIX
References: <1312624768-2394-1-git-send-email-luk@debian.org>
In-Reply-To: <1312624768-2394-1-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/06/2011 05:59 AM, Luk Claes wrote:
> sh -p is not guaranteed to be provided by POSIX shells. dash for instance does not provide this, so use bash explicitly.
> 
> Signed-off-by: Luk Claes <luk@debian.org>
> ---
>  utils/statd/start-statd |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index c7805ee..1b345a5 100644
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -1,8 +1,8 @@
> -#!/bin/sh -p
> +#!/bin/bash -p
>  # nfsmount calls this script when mounting a filesystem with locking
>  # enabled, but when statd does not seem to be running (based on
>  # /var/run/rpc.statd.pid).
> -# It should run run statd with whatever flags are apropriate for this
> +# It should run statd with whatever flags are apropriate for this
>  # site.
>  PATH=/sbin:/usr/sbin
>  exec rpc.statd --no-notify
Committed...

steved.
