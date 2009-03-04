From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Don't convert NFS4ERR_RESOURCE to EREMOTEIO
Date: Wed, 4 Mar 2009 14:35:19 -0500
Message-ID: <20090304193519.GC28951@fieldses.org>
References: <49AECB96.5010909@uvm.edu> <20090304190156.GA27567@fieldses.org> <1236195010.7807.26.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Coddington <Benjamin.Coddington@uvm.edu>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40427 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522AbZCDTfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 14:35:21 -0500
In-Reply-To: <1236195010.7807.26.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2009 at 02:30:10PM -0500, Trond Myklebust wrote:
> On Wed, 2009-03-04 at 14:01 -0500, J. Bruce Fields wrote:
> > On Wed, Mar 04, 2009 at 01:42:30PM -0500, Benjamin Coddington wrote:
> > > Fixes a test in nfs4_proc_setclientid_confirm() which allows the client  
> > > to retry an operation when the server returns NFS4ERR_RESOURCE, instead  
> > > of returning EREMOTEIO to the user.
> > 
> > I remember being confused as to whether NFS4ERR_RESOURCE is transitory
> > (hence worth being retried) or permanent (in which case retrying the
> > identical compound won't help).  The latter might happen if, for
> > example, the particular sequence of compounds sent by the client was
> > just too long or complicated for the server to handle.
> > 
> > But rfc3530 doesn't explicitly limit NFS4ERR_RESOURCE to that case, and
> > it appears that other clients:
> > 
> > 	http://www.nfsv4.org/nfsv4-wg-archive-feb-03-feb-05/0747.html
> > 
> > retry.  That discussion isn't conclusive, though.  Hm, and there's
> > further discussion from Mike Eisler here:
> > 
> > 	http://www.nfsv4-editor.org/cgi-bin/roundup/nfsv4/file7/comp-res.txt
> > 
> > which suggests it was intended as a permanent error.
> >
> > What was the specific case where you hit this?
> 
> He says it was in SETCLIENTID_CONFIRM.
> 
> AIX used to abuse the NFS4ERR_RESOURCE error in order to delay clients
> while the server was doing some preparations for state recovery. They
> argues that they couldn't use NFS4ERR_DELAY since it isn't listed as a
> legal error for SETCLIENTID_CONFIRM in RFC3530,

Oh, good grief, I'd forgotten that story.  OK!--b.

> and so they picked
> NFS4ERR_RESOURCE. That would be a server bug...
