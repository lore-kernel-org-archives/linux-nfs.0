From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] [RESEND] NFS: Handle -ESTALE error in access()
Date: Mon, 09 Mar 2009 08:55:57 -0400
Message-ID: <1236603357.7234.12.camel@heimdal.trondhjem.org>
References: <49B50F7E.9080500@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45396 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbZCIM4E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Mar 2009 08:56:04 -0400
In-Reply-To: <49B50F7E.9080500@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-03-09 at 18:15 +0530, Suresh Jayaraman wrote:
> Hi Trond,
> 
> I sent this patch a while ago and I guess it's got lost admist busy
> cthon'09 and FAST '09 schedules. So, resending for consideration and
> inclusion.

It has been in my testing tree for some time. I'll be publishing that in
the official git tree soon.

Trond

