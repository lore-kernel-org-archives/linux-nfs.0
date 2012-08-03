Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:37163 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751588Ab2HCCik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 22:38:40 -0400
Received: from sc9-mailhost1.vmware.com (sc9-mailhost1.vmware.com [10.113.161.71])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 045192823E
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 19:29:15 -0700 (PDT)
Received: from zimbra-prod-mta-2.vmware.com (zimbra-prod-mta-2.vmware.com [10.113.160.174])
	by sc9-mailhost1.vmware.com (Postfix) with ESMTP id 00A3A181F1
	for <linux-nfs@vger.kernel.org>; Thu,  2 Aug 2012 19:29:15 -0700 (PDT)
Date: Thu, 2 Aug 2012 19:29:14 -0700 (PDT)
From: Andrei Warkentin <awarkentin@vmware.com>
To: linux-nfs@vger.kernel.org
Cc: Ed Goggin <egoggin@vmware.com>
Message-ID: <1592211005.4733808.1343960954717.JavaMail.root@vmware.com>
In-Reply-To: <1781697815.4540720.1343959078882.JavaMail.root@vmware.com>
Subject: Re: stale or not stale
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Ed Goggin" <egoggin@vmware.com>
> To: linux-nfs@vger.kernel.org
> Sent: Thursday, August 2, 2012 9:57:58 PM
> Subject: stale or not stale
> 
> 
> It seems that nfsd can return reply attributes with a link count of
> zero but without an NFS3ERR_STALE status.  We've seen this actually
> happen for a write request to a file with a single link that  is
> concurrently being removed without NLM lock protection.  What is the
> proper behavior here?

I think it would be worthwhile to add here that the the remove was not concurrent with the write, and at the time of the NFS write a new file with the same name existed, yet fh decoding picked up the old inode instead of reporting -ESTALE. FS was ext4.

In fact seen two things happen - n_link = 0 and n_link = 1, and in both cases we knew the file was unlink()ed and re-creat()ed.

A
