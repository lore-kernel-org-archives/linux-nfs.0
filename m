Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout1.thls.bbc.co.uk ([132.185.240.36]:60496 "EHLO
	mailout1.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953Ab0LHPcH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 10:32:07 -0500
Date: Wed, 8 Dec 2010 15:31:21 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 client in 20Mbit/sec fight with NFS server
Message-ID: <20101208153121.GC20844@rd.bbc.co.uk>
References: <20101104233705.GM12804@rd.bbc.co.uk>
 <1288966729.13204.6.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288966729.13204.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > I am currently seeing a sustained ~20Mbit/sec of traffic from an NFS(v4)
> > client, seemingly never completing the operation it desires.
> The following patch has been committed to 2.6.37-rc1 in order to fix a
> similar situation. Can you please try it and see if it fixes yours too?
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c

Thank you for the patch, I have applied this to 2.6.35.8 and have been
running it for about a month now, and the problem hasn't occured again.
That said however, I wasn't able to recreate the issue under the
previous kernel.

Kind regards,

..david
