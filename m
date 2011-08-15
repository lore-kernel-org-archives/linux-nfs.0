Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53719 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab1HOQDf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2011 12:03:35 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: open() of device special files
Date: Mon, 15 Aug 2011 09:03:30 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110815153637.GD28629@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Cc: <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, August 15, 2011 11:37 AM
> To: Myklebust, Trond; linux-nfs@vger.kernel.org
> Cc: steved@redhat.com
> Subject: open() of device special files
> 
> How is the client supposed to handle opens of device special files?
On
> a 3.1-rc1-based client to a linux server over v4.0 I'm seeing it try
an
> OPEN call and failing when it gets an INVAL return.
> 
> This looks like bogus client behavior (OPEN should fail on such
files),
> unless the server has the error return wrong and the client's using an
> OPEN error to recover.
> 
> If I first stat the device and then open it then it works as expected
> (the client does an open of the local device).
> 
> I'm a bit annoyed at myself as I have a feeling we've discussed this
> before but I can't find a reference now.

Hmm... NFS4ERR_INVAL means 'invalid argument', which is not the case
here; all the arguments that the client is passing to the server are
valid, however the file cannot be opened because the pathname resolves
on the server to a file of the wrong type.

I can't see any other error definition that is "obviously correct", but
it looks to me as if NFS4ERR_SYMLINK might be the closest thing. One
reason is the dot-x file defines NFS4ERR_SYMLINK as meaning "should be
file/directory". The other reason is that NFS4ERR_SYMLINK should
_always_ trigger the correct behaviour on a client: a fresh lookup of
the component.

Cheers
  Trond
