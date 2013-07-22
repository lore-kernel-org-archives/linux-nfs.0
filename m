Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:1978 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933328Ab3GVUY1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 16:24:27 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 4 2/2] NFSv4.1 Use the MDS nfs_server authflavor
 for pNFS data server connections
Date: Mon, 22 Jul 2013 20:24:25 +0000
Message-ID: <5AD98A36-80F4-4B07-8C87-2D0CE4253A19@netapp.com>
References: <1374267997-4305-1-git-send-email-andros@netapp.com>
 <1374267997-4305-2-git-send-email-andros@netapp.com>
 <1374519051.7972.18.camel@leira.trondhjem.org>
In-Reply-To: <1374519051.7972.18.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 2:50 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Fri, 2013-07-19 at 17:06 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> pNFS data servers are not mounted in the normal sense as there is no associated
>> nfs_server structure.
>> Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
>> uses the nfs_client cl_rpcclient for all state management operations, and
>> will use krb5i or auth_sys with no regard to the mount command authflavor
>> choice.  For normal mounted servers, the nfs_server client authflavor is used
>> for all non-state management operations
>> 
>> Data servers also need to use the same authflavor as the MDS mount for
>> non-state management operations. Add a strut rpc_clnt to struct nfs_client for
>> data server connections.
> 
> Is that sufficient? As far as I can tell, there is nothing that states
> that the data servers must use the same security mechanism for all the
> files?
> In fact, section 13.12 specifically mentions that the data servers have
> to support SECINFO_NO_NAME to allow clients to figure out what to use
> for a given DS filehandle.

Good point.  We don't support per-file security, but we do support per fsid security and the DS should follow suit.

A non-pNFS NFSv4.1 mount can switch auth flavors on fsid boundaries - under the cover mount, create nfs_server with it's own rpc_clnt and a different security flavor. So what to do in the DS case where the DS exports more than one fsid, each with a different security flavor?

I discussed this with Dros who is also doing some work on the SECINFO code. As a first pass, it would make sense to use the security flavor that the MDS server->client uses for DS access, and replace the single data server rpc_clnt with an array of rpc_clnts one for each flavor (sys, krb5, krb5i, krb5p)  that get allocated (for the DS-only case) when first needed and cached.

For the MDS + DS case this cache could also be used by the MDS nfs_server->clients.

Is this what you had in mind?

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

