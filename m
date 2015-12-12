Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43588 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbbLLMOV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:14:21 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 555DA552E7
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 12:14:21 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-47.rdu2.redhat.com [10.10.54.47])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tBCCEKl9025079
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 07:14:20 -0500
Subject: Re: [PATCH 2/2] rpc.idmapd: Added the -C and -S flags
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1449676902-19575-1-git-send-email-steved@redhat.com>
 <1449676902-19575-2-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0F9C.1000603@RedHat.com>
Date: Sat, 12 Dec 2015 07:14:20 -0500
MIME-Version: 1.0
In-Reply-To: <1449676902-19575-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/09/2015 11:01 AM, Steve Dickson wrote:
> The C and S flags were missing for the SYNOPSIS
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed....

steved.

> ---
>  utils/idmapd/idmapd.man | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
> index c809f78..d45658e 100644
> --- a/utils/idmapd/idmapd.man
> +++ b/utils/idmapd/idmapd.man
> @@ -10,8 +10,10 @@
>  .Sh SYNOPSIS
>  .\" For a program:  program [-abc] file ...
>  .Nm rpc.idmapd
> -.Op Fl v
>  .Op Fl f
> +.Op Fl v
> +.Op Fl C
> +.Op Fl S
>  .Op Fl p Ar path
>  .Op Fl c Ar path
>  .Sh DESCRIPTION
> 
