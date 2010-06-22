From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] mountd.nfs: Better error diagnostics for the mount
 command (take 3)
Date: Tue, 22 Jun 2010 16:15:36 -0400
Message-ID: <4C2119E8.9010707@RedHat.com>
References: <1275583898-17908-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698Ab0FVUPi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 16:15:38 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o5MKFblZ021404
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 16:15:37 -0400
In-Reply-To: <1275583898-17908-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2010 12:51 PM, Steve Dickson wrote:
> [I've incorporated the last few code review comments]
> 
> The following two patches add better error diagnostics when
> invalid option values are given and when the network protocol
> can not be determined. 
> 
> Steve Dickson (2):
>   mount: silently fails when bad option values are given
>   mount.nfs: silently fails when the network protocol is not found
> 
>  utils/mount/network.c   |   59 ++++++++++++++++++++++++++++++++++++----------
>  utils/mount/nfsumount.c |    4 +--
>  utils/mount/stropts.c   |   16 ++++++++----
>  3 files changed, 58 insertions(+), 21 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Committed... 

steved.
