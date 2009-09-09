From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Wed, 09 Sep 2009 18:56:10 -0400
Message-ID: <1252536970.8722.110.camel@heimdal.trondhjem.org>
References: <4AA68AA4.7090606@moving-picture.com>
	 <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>
	 <4AA8225A.9060107@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56191 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbZIIW4L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 18:56:11 -0400
In-Reply-To: <4AA8225A.9060107-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-09-09 at 22:47 +0100, James Pearson wrote:
> The default behaviour with binary mount options when no [rw]size is to 
> select these preferred values - which to me, makes sense - as by not 
> giving a [rw]size, you are leaving it up the server to pick the 'best' 
> values for you - which I guess in most (all other?) cases happen to be 
> the maximum size.

Right. The above was indeed the guiding principle back when I did the
rsize/wsize negotiation for NFSv3 and NFSv2 for the binary mount code.

The NFS protocol specifies that the maximum values are there to tell you
that the server will do short read/writes if you exceed these. However,
the preferred values may correspond to a different 'sweet spot' for the
server read and write implementations.

Cheers
    Trond

