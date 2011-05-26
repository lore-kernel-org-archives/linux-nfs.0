Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64962 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756358Ab1EZPTj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 11:19:39 -0400
Subject: More NFSv4.1 issues [WAS: Re: [RFC] pnfs: Send layoutreturn, if
 Return-On-Close is set]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Thu, 26 May 2011 11:19:21 -0400
In-Reply-To: <1306422257.2984.21.camel@lade.trondhjem.org>
References: <4DDE536E.8020805@panasas.com>
	 <1306419397.2984.14.camel@lade.trondhjem.org> <4DDE6783.5@panasas.com>
	 <1306422257.2984.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306423161.2984.26.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-26 at 11:04 -0400, Trond Myklebust wrote: 
> See the description of the EXCHGID4_FLAG_BIND_PRINC_STATEID exchangeid
> flag. Although we don't set that flag in our exchangeid requests, the
> _server_ may still set it in its reply, in which case we are supposed to
> obey it.
> This is also a reason why sending OPEN and LAYOUTGET in the same
> compound can be problematic.

BTW: We have yet to implement support for BIND_PRINC_STATEID in the
client. One of the more "interesting" issues, I think, is that we
probably want to handle EKEYEXPIRED differently: instead of just
retrying, we should really clear out the layouts (forgetfully - since we
don't have a credential) and reget them.

Note that SP4_MACH_CRED and SP4_SSV might help here, but we're not
guaranteed that the server supports those even if it requires
BIND_PRINC_STATEID.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

