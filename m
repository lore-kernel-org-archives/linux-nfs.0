Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932266Ab1LEOpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 09:45:41 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pB5EjemC030844
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Dec 2011 09:45:41 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-58.rdu.redhat.com [10.11.9.58])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pB5Ejeoh005662
	for <linux-nfs@vger.kernel.org>; Mon, 5 Dec 2011 09:45:40 -0500
Message-ID: <4EDCD913.40300@RedHat.com>
Date: Mon, 05 Dec 2011 09:45:39 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] nfsidmap: Allow admins to clean up id mappings that
 have (ver 3)
References: <1322061842-1806-1-git-send-email-steved@redhat.com>
In-Reply-To: <1322061842-1806-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2011 10:24 AM, Steve Dickson wrote:
> In working with the new idmapper, it became very apparent that
> keys created from bad id mapping were very persistent and were
> not easy disposed of. Unlike with rpc.idmapd, to git rid 
> of bad id mapping one just needed to restart the daemon. 
> 
> So I've added some functionality to the nfsidmap command
> that will allow admins to:
> 
>     - remove all the keys on the keyring.
>     - remove a particular key from the keying.
> 
> The intention is to allow admins a way to clean up the id
> name space when name resolution mechanisms, like NIS or LDAP, 
> fail and leave a large number (or small number) of id mapping 
> pointing to nobody. 
> 
> Note, for the second patch to work, there need to be a small 
> kernel patch that will change the per-key permissions to
> allow root to revoke them.
> 
> Version 2:
> - Added the fclose() calls as requested by the code review
> Version 3:
> - Confined the -c flag to only remove keys from the id_resolver keyring.
Committed...

steved.
> 
> Steve Dickson (2):
>   nfsidmap: Allow keys to be cleared from the keyring
>   nfsidmap: Allow a particular key to be revoked.
> 
>  utils/nfsidmap/nfsidmap.c   |  148 +++++++++++++++++++++++++++++++++++++++++--
>  utils/nfsidmap/nfsidmap.man |   25 +++++++-
>  2 files changed, 167 insertions(+), 6 deletions(-)
> 
