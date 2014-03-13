Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbaCMPYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 11:24:42 -0400
Message-ID: <5321CDB6.7010803@RedHat.com>
Date: Thu, 13 Mar 2014 11:24:38 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Noam Meltzer <noam@primarydata.com>, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
In-Reply-To: <1393918676-20865-1-git-send-email-noam@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 03/04/2014 02:37 AM, Noam Meltzer wrote:
> Hello sssd-devel & linux-nfs,
> 
> This is v2 of the patch set. It is now sent to linux-nfs as weel, following
> Steve Dickson request.
> 
> The code in the next 5 patches implements the design document:
> https://fedorahosted.org/sssd/wiki/DesignDocs/rpc.idmapd%20plugin
> 
> The changes in the code (compared to v1) are following the review done in
> sssd-devel.
> I believe that there are still two items in dispute (no final verdict was given
> in the sssd mailing list) but this new patch set will give a chance to have a
> cleaner look on things.
What exactly are you looking for from us to move this forward? 

I would like to point out that the NFS client no longer uses the
rpc.idmapd daemon to do its id mapping. Instead the kernel now 
does an upcall to the nfsidmap(5) command and the resulting 
uid/gid is stored in the kernel key chain, if a mapping 
is done at all... 

V4 servers now have an option of returning a uid string (aka "3606")
where the NFS client just converts that into the uid.

steved.

> 
> --
> 
> Noam Meltzer
> Linux Software Engineer
> PRIMARY DATA
> 
> P.O. Box 12650, Herzliya Pituach 4673300
> 9 Hamenofim St. Akerstein Towers, Tower A, 5th fl. Herzliya
> 
> Office: +972-77-8981888 | Fax: +972-3-7617140 | Mobile: +972-54-5873843
> 
> Email: noam@primarydata.com
> 
> 
> --
> 
> Noam Meltzer (5):
>   NEW CLIENT: plugin for NFSv4 rpc.idmapd
>   NFSv4 client: (private) headers from libnfsidmap
>   NFSv4 client: add to build system
>   NFSv4 client: man page
>   NFSv4 client: add to RPM spec
> 
>  Makefile.am                            |  19 ++
>  configure.ac                           |  10 +
>  contrib/sssd.spec.in                   |   8 +
>  src/conf_macros.m4                     |  30 ++
>  src/external/libnfsidmap.m4            |  17 +
>  src/man/Makefile.am                    |   4 +-
>  src/man/include/seealso.xml            |   4 +
>  src/man/sss_rpcidmapd.5.xml            |  97 ++++++
>  src/sss_client/common.c                |   5 +
>  src/sss_client/nfs/nfsidmap_internal.h |  78 +++++
>  src/sss_client/nfs/sss_nfs_client.c    | 569 +++++++++++++++++++++++++++++++++
>  src/sss_client/sss_cli.h               |   2 +
>  12 files changed, 842 insertions(+), 1 deletion(-)
>  create mode 100644 src/external/libnfsidmap.m4
>  create mode 100644 src/man/sss_rpcidmapd.5.xml
>  create mode 100644 src/sss_client/nfs/nfsidmap_internal.h
>  create mode 100644 src/sss_client/nfs/sss_nfs_client.c
> 
