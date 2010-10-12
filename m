Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24332 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758216Ab0JLToM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 15:44:12 -0400
Subject: Re: whither NFS umount?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101012151826.76b75f52@corrin.poochiereds.net>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
	 <1286903046.24878.13.camel@heimdal.trondhjem.org>
	 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
	 <20101012151826.76b75f52@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Oct 2010 15:44:09 -0400
Message-ID: <1286912649.1956.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:

> I think the part that causes problems is having userspace do this. In
> theory, if the kernel were in charge of sending the UMNT, then it's not
> really a problem since it knows when to do it. If we have code that
> sends a UMNT already, why not do a best-effort UMNT call from the
> kernel when we tear down the sb?

Purely for the pleasure of allowing the server to maintain inaccurate
statistics about who is currently mounting what? I think not...

You can get far more accurate results by replacing the MNT/UMNT state
counter with a purely server-based scheme to track who accessed one or
more files on each exported partition in the past 5 minutes or so. That
would even work with NFSv4...

> Either way, eliminating umount.nfs would be nice...

Agreed.

Trond
