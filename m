Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62788 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932204Ab1LEUVs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 15:21:48 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Empty core dumps on NFSv4 mounts
Date: Mon, 5 Dec 2011 12:21:46 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544D7C@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <A288911B-E32B-4C09-9662-C30C5E2EEB33@oracle.com>
References: <AD82E120-D2B9-4C11-A622-970C951BD4F4@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544D70@SACMVEXC2-PRD.hq.netapp.com> <A288911B-E32B-4C09-9662-C30C5E2EEB33@oracle.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Monday, December 05, 2011 3:19 PM
> To: Myklebust, Trond
> Cc: Linux NFS Mailing List
> Subject: Re: Empty core dumps on NFSv4 mounts
> 
> 
> On Dec 5, 2011, at 3:14 PM, Myklebust, Trond wrote:
> 
> > No. There have been no kernel idmapper changes since then.
> >
> > The correct thing to do here is to cache the string name in struct
> > nfs_fattr, and then do the upcall from the caller of OPEN. I believe
> > that Arnaud wrote a patch to do this, however the whole pNFS merge
got
> > in my way of reviewing this. Feel free to take a look at what he
did,
> > and post comments...
> 
> We're looking at his patch, from July 2010, now.  It calls kmalloc()
in the XDR
> decoder.  Is there a newer version?

Not as far as I know, and I agree that calling kmalloc in the XDR is a
problem... If, however, we can accept that it will occasionally fail,
then perhaps kmalloc(GFP_NOWAIT) might be acceptable?

Cheers
  Trond

