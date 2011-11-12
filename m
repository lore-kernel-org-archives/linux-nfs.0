Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43491 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201Ab1KLDgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 22:36:03 -0500
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 11 Nov 2011 22:36:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAC3ZiKb3477580
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 22:35:44 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAC3ZNkj026124
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 20:35:23 -0700
Received: from malahal ([9.47.25.235])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id pAC3ZMnK026087
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 20:35:22 -0700
Date: Fri, 11 Nov 2011 19:35:20 -0800
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 1/7] New mount option for volatile filehandle
 recovery
Message-ID: <20111112033520.GA15724@us.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321052673-22171-2-git-send-email-treinish@linux.vnet.ibm.com>
 <1321057177.8733.8.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321057177.8733.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> > The new 'vfhretry' mount option will be used to enable the volatile filehandle
> > recovery routines in the client. On an expired filehandle recover the client
> > will attempt to recover by performing a lookup on the name of the file.
> > 
> > This mechanism of recovery isn't necessarily safe for a posix filesystem so
> > using the mount option will allow the user to enable this at their own risk. If the mount option is not turned on, the FHEXPIRED error will be converted to
> > ESTALE.
> 
> Either we handle NFS4ERR_FHEXPIRED, or we don't... What is the
> justification for wanting to turn this off on a per-mount basis?

VFH should work with read-only file systems. Is there a way to find if
the exported file system is read-only? If there is, Matt should use that
instead of using this mount option.

--Malahal.

