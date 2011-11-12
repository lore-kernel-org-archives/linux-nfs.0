Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554Ab1KLANb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 19:13:31 -0500
Message-ID: <1321056809.8733.2.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Matthew Treinish <treinish@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 11 Nov 2011 19:13:29 -0500
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> This patch series implements client side support for volatile file handle
> recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
> test the client you either need a server that supports volatile file handles or 
> you can hard code the server to output NFS4ERR_FHEXPIRED instead of
> NFSERR_STALE. (See the last patch in the series)

WHY do we want to support this kind of "feature"? As you said, the RFC
doesn't actually help in figuring out how this crap is supposed to work
in practice, so why do we even consider starting to give a damn?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

