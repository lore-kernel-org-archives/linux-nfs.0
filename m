Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36665 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754782AbZCDTac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 14:30:32 -0500
Subject: Re: [PATCH] Don't convert NFS4ERR_RESOURCE to EREMOTEIO
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Benjamin Coddington <Benjamin.Coddington@uvm.edu>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20090304190156.GA27567@fieldses.org>
References: <49AECB96.5010909@uvm.edu> <20090304190156.GA27567@fieldses.org>
Content-Type: text/plain
Date: Wed, 04 Mar 2009 14:30:10 -0500
Message-Id: <1236195010.7807.26.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-03-04 at 14:01 -0500, J. Bruce Fields wrote:
> On Wed, Mar 04, 2009 at 01:42:30PM -0500, Benjamin Coddington wrote:
> > Fixes a test in nfs4_proc_setclientid_confirm() which allows the client  
> > to retry an operation when the server returns NFS4ERR_RESOURCE, instead  
> > of returning EREMOTEIO to the user.
> 
> I remember being confused as to whether NFS4ERR_RESOURCE is transitory
> (hence worth being retried) or permanent (in which case retrying the
> identical compound won't help).  The latter might happen if, for
> example, the particular sequence of compounds sent by the client was
> just too long or complicated for the server to handle.
> 
> But rfc3530 doesn't explicitly limit NFS4ERR_RESOURCE to that case, and
> it appears that other clients:
> 
> 	http://www.nfsv4.org/nfsv4-wg-archive-feb-03-feb-05/0747.html
> 
> retry.  That discussion isn't conclusive, though.  Hm, and there's
> further discussion from Mike Eisler here:
> 
> 	http://www.nfsv4-editor.org/cgi-bin/roundup/nfsv4/file7/comp-res.txt
> 
> which suggests it was intended as a permanent error.
>
> What was the specific case where you hit this?

He says it was in SETCLIENTID_CONFIRM.

AIX used to abuse the NFS4ERR_RESOURCE error in order to delay clients
while the server was doing some preparations for state recovery. They
argues that they couldn't use NFS4ERR_DELAY since it isn't listed as a
legal error for SETCLIENTID_CONFIRM in RFC3530, and so they picked
NFS4ERR_RESOURCE. That would be a server bug...

Trond

