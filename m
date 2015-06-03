Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932500AbbFCTDQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2015 15:03:16 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 00A2B36504C
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2015 19:03:15 +0000 (UTC)
Message-ID: <556F4F71.2060301@RedHat.com>
Date: Wed, 03 Jun 2015 15:03:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] mountstats: Fix the retrans counter output
 by the nfsstat command
References: <1431531681-64765-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1431531681-64765-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/13/2015 11:41 AM, Scott Mayhew wrote:
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  tools/mountstats/mountstats.py | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed... 

steved.

> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 38943eb..011bb42 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -474,7 +474,7 @@ class DeviceData:
>          # authrefresh stats don't actually get captured in
>          # /proc/self/mountstats, so we fudge it here
>          authrefrsh = sends
> -        return (sends, trans, authrefrsh)
> +        return (sends, retrans, authrefrsh)
>  
>      def display_nfsstat_stats(self):
>          """Pretty-print nfsstat-style stats
> 
