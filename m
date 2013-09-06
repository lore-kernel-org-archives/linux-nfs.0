Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:42993 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709Ab3IFTRN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2013 15:17:13 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 1/1] NFSv4.1 Use MDS auth flavor for data
 server connection
Date: Fri, 6 Sep 2013 19:17:11 +0000
Message-ID: <A25844A6-98C0-473F-9ABF-E10320BC18FA@netapp.com>
References: <1378491240-1848-1-git-send-email-andros@netapp.com>
 <1378493274.10582.14.camel@leira.trondhjem.org>
In-Reply-To: <1378493274.10582.14.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 6, 2013, at 2:47 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Fri, 2013-09-06 at 14:14 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
>> uses the nfs_client cl_rpcclient for all state management operations, and
>> will use krb5i or auth_sys with no regard to the mount command authflavor
>> choice.
>> 
>> The MDS, as any NFSv4.1 mount point, uses the nfs_server rpc client for all
>> non-state management operations with a different nfs_server for each fsid
>> encountered traversing the mount point, each with a potentially different
>> auth flavor.
>> 
>> pNFS data servers are not mounted in the normal sense as there is no associated
>> nfs_server structure. Data servers can also export multiple fsids, each with
>> a potentially different auth flavor.
>> 
>> Data servers need to use the same authflavor as the MDS server rpc client for
>> non-state management operations. Populate a list of rpc clients with the MDS
>> server rpc client auth flavor for the DS to use.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> 
> 
> Thank you Andy! Unless something comes up, I'm applying this one.

Good - thanks for all the valuable review :)

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

