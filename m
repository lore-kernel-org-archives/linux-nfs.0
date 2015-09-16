Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbbIPTJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 15:09:29 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 7589F8E689
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 19:09:29 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] mountstats.man: Remove a few bogus .R macros
To: Scott Mayhew <smayhew@redhat.com>
References: <1442325678-52516-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F9BE68.6010906@RedHat.com>
Date: Wed, 16 Sep 2015 15:09:28 -0400
MIME-Version: 1.0
In-Reply-To: <1442325678-52516-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/15/2015 10:01 AM, Scott Mayhew wrote:
> These have no effect on the rendering of the man page, but they do cause
> the following error if you try to pipe or redirect the output:
> 
> `R' is a string (producing the registered sign), not a macro.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  tools/mountstats/mountstats.man | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
> index bfc4c46..a55130b 100644
> --- a/tools/mountstats/mountstats.man
> +++ b/tools/mountstats/mountstats.man
> @@ -13,13 +13,13 @@ mountstats \- Displays various NFS client per-mount statistics
>  .RB [ \-S | \-\-since
>  .IR sincefile ]
>  .\" .RB [ \-n | \-\-nfs | \-r | \-\-rpc | \-R | \-\-raw ]
> -.R [
> +[
>  .RB [ \-n | \-\-nfs ]
> -.R |
> +|
>  .RB [ \-r | \-\-rpc ]
> -.R |
> +|
>  .RB  [ \-R | \-\-raw ]
> -.R ]
> +]
>  .RI [ mountpoint ] ...
>  .P
>  .B mountstats iostat
> 
