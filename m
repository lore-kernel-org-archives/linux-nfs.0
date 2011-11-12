Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554Ab1KLATl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 19:19:41 -0500
Message-ID: <1321057177.8733.8.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 1/7] New mount option for volatile filehandle
 recovery
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Matthew Treinish <treinish@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 11 Nov 2011 19:19:37 -0500
In-Reply-To: <1321052673-22171-2-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321052673-22171-2-git-send-email-treinish@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> The new 'vfhretry' mount option will be used to enable the volatile filehandle
> recovery routines in the client. On an expired filehandle recover the client
> will attempt to recover by performing a lookup on the name of the file.
> 
> This mechanism of recovery isn't necessarily safe for a posix filesystem so
> using the mount option will allow the user to enable this at their own risk. If the mount option is not turned on, the FHEXPIRED error will be converted to
> ESTALE.

Either we handle NFS4ERR_FHEXPIRED, or we don't... What is the
justification for wanting to turn this off on a per-mount basis?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

