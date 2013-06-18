Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:5743 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755926Ab3FRPJt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 11:09:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christopher T Vogan <cvogan@us.ibm.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Date: Tue, 18 Jun 2013 15:09:35 +0000
Message-ID: <1371568176.3868.5.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
In-Reply-To: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-18 at 07:47 -0600, Christopher T Vogan wrote:
> The new linux 3.10.0-rc5 kernel gets NFSERR_STALE on un-mount.
> The reason is the Linux client is sending a GETATTR after the umnt 
> call/reply.
> This is a network trace of the umnt call/reply and the gettattr 
> afterwords.

This happens because the 'umount.nfs' utility calls the umnt RPC before
the actual umount system call.

Why would this trigger an NFSERR_STALE? Is the server using UMNT for
something other than just providing client usage stats? If so, what and
why?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
