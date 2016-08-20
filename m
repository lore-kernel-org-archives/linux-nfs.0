Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54728 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752752AbcHTOzf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Aug 2016 10:55:35 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CCBF3C049D59
        for <linux-nfs@vger.kernel.org>; Sat, 20 Aug 2016 14:55:34 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-56-229.rdu2.redhat.com [10.10.56.229])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7KEtYZU021384
        for <linux-nfs@vger.kernel.org>; Sat, 20 Aug 2016 10:55:34 -0400
Subject: Re: [RFC PATCH 3/3] nfs-utils: Update rpc.idmap and nfsidmap man
 pages
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1471545435-15543-1-git-send-email-steved@redhat.com>
 <1471545435-15543-3-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <a78d57eb-7f64-2e76-de8a-5951c5744fc3@RedHat.com>
Date: Sat, 20 Aug 2016 10:55:34 -0400
MIME-Version: 1.0
In-Reply-To: <1471545435-15543-3-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/18/2016 02:37 PM, Steve Dickson wrote:
> Describe how the NFSv4 domain name can be
> now be found using the _nfsv4idmapdomain DNS
> TXT record
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  utils/idmapd/idmapd.man     | 23 +++++++++++++++++++++++
>  utils/nfsidmap/nfsidmap.man |  9 +++++++++
>  2 files changed, 32 insertions(+)
> 
> diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
> index b9200c7..d4ab894 100644
> --- a/utils/idmapd/idmapd.man
> +++ b/utils/idmapd/idmapd.man
> @@ -23,6 +23,29 @@ is the NFSv4 ID <-> name mapping daemon.  It provides functionality to
>  the NFSv4 kernel client and server, to which it communicates via
>  upcalls, by translating user and group IDs to names, and vice versa.
>  .Pp
> +The system derives the
> +.I user
> +part of the string by performing a password or group lookup.
> +The lookup mechanism is configured in
> +.Pa /etc/idmapd.conf
> +.Pp
> +By default, the
> +.I domain
> +part of the string is the system's DNS domain name.
> +It can also be specified in
> +.Pa /etc/idmapd.conf
> +if the system is multi-homed,
> +or if the system's DNS domain name does
> +not match the name of the system's Kerberos realm.
> +.Pp
> +When the domain is not specified in /etc/idmapd.conf
> +the local DNS server will be queried for the 
> +.Sy _nfsv4idmapdomain 
> +text record. If the record exists
> +that will be used as the domain. When the record
> +does not exist, the domain part of the DNS domain
> +will used. 
> +.Pp
>  Note that on more recent kernels only the NFSv4 server uses
>  .Nm .
>  The NFSv4 client instead uses
> diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
> index 2f17cf2..2af16f3 100644
> --- a/utils/nfsidmap/nfsidmap.man
> +++ b/utils/nfsidmap/nfsidmap.man
> @@ -39,6 +39,15 @@ if the system is multi-homed,
>  or if the system's DNS domain name does
>  not match the name of the system's Kerberos realm.
>  .PP
> +When the domain is not specified in 
> +.I /etc/idmapd.conf
> +the local DNS server will be queried for the 
> +.I _nfsv4idmapdomain 
> +text record. If the record exists
> +that will be used as the domain. When the record
> +does not exist, the domain part of the DNS domain
> +will used. 
> +.PP
>  The
>  .I /usr/sbin/nfsidmap
>  program performs translations on behalf of the kernel.
> 
