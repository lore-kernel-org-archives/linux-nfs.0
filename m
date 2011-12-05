Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40575 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932488Ab1LEUOy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 15:14:54 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Empty core dumps on NFSv4 mounts
Date: Mon, 5 Dec 2011 12:14:48 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544D70@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <AD82E120-D2B9-4C11-A622-970C951BD4F4@oracle.com>
References: <AD82E120-D2B9-4C11-A622-970C951BD4F4@oracle.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No. There have been no kernel idmapper changes since then.

The correct thing to do here is to cache the string name in struct
nfs_fattr, and then do the upcall from the caller of OPEN. I believe
that Arnaud wrote a patch to do this, however the whole pNFS merge got
in my way of reviewing this. Feel free to take a look at what he did,
and post comments...

Cheers
  Trond

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Monday, December 05, 2011 3:10 PM
> To: Myklebust, Trond
> Cc: Linux NFS Mailing List
> Subject: Empty core dumps on NFSv4 mounts
> 
> Bump.
> 
> http://comments.gmane.org/gmane.linux.nfs/33390
> 
> We have evidence that this is still occurring as late as 3.0.  Have
recent
> idmapper changes addressed this issue?
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 

