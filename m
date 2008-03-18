From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Tue, 18 Mar 2008 12:43:56 +1100
Message-ID: <47DF1E5C.9090607@melbourne.sgi.com>
References: <200803172021.08327.nfs@share-foo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:52367 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752599AbYCRBkO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2008 21:40:14 -0400
In-Reply-To: <200803172021.08327.nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ray Ferguson wrote:
> I've discovered a bug in the linux nfs client.  Specifically it ignores 
> NFSERR_NOSPC messages (code 28) from an NFS server and happily continues 
> pounding it with data.
>   

It doesn't ignore ENOSPC, it reports it on close().  Of course this is
often several gigabytes of lost data too late.

Sensible clients (e.g. Irix) store that error on the inode and report it
on the next call to write().

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

