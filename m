Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435AbcFUQdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 12:33:32 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C3487F0B3
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 16:09:48 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5LG9lnP014668
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 12:09:47 -0400
Subject: Re: [PATCH 1/1] start-statd: Use flock to serialize the running of
 this script
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1466441099-16166-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <40249c38-7ebb-a7f7-70cc-035c8fb9854b@RedHat.com>
Date: Tue, 21 Jun 2016 12:09:47 -0400
MIME-Version: 1.0
In-Reply-To: <1466441099-16166-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/20/2016 12:44 PM, Steve Dickson wrote:
> To once and for all stop multiple rpc.statd from
> being started (mostly in HA environments), use
> flock to serialize the running of the script
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  utils/statd/start-statd | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index 19e6eb2..2fd6039 100755
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -6,6 +6,10 @@
>  # site.
>  PATH="/sbin:/usr/sbin:/bin:/usr/bin"
>  
> +# Use flock to serialize the running of this script
> +exec 200> /var/run/rpc.statd.lock
> +flock -e 200
> +
>  if [ -s /var/run/rpc.statd.pid ] &&
>         [ 1`cat /var/run/rpc.statd.pid` -gt 1 ] &&
>         kill -0 `cat /var/run/rpc.statd.pid` > /dev/null 2>&1
> 
