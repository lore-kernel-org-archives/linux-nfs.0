From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Thu, 04 Dec 2008 14:57:45 -0500
Message-ID: <1228420665.7475.19.camel@heimdal.trondhjem.org>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>
	 <1228411011.7475.6.camel@heimdal.trondhjem.org>
	 <1228411282.7475.9.camel@heimdal.trondhjem.org>
	 <89c397150812041050u184afda7s2d33bc1aa82b8171@mail.gmail.com>
	 <1228417616.7475.16.camel@heimdal.trondhjem.org>
	 <89c397150812041116t74692ca1k5ce2ca87e64b5a2b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39048 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751518AbYLDT54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 14:57:56 -0500
In-Reply-To: <89c397150812041116t74692ca1k5ce2ca87e64b5a2b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-12-04 at 14:16 -0500, William A. (Andy) Adamson wrote:
> >> and the one that I saw when I tried to mount a v4.0 server with a v4.1
> >> client which caused a segfault.
> >>
> >> NFS4ERR_MINOR_VERS_MISMATCH.
> >
> > Should never happen on a v4.0 client...

Hmm...

That said, it wouldn't harm to add the MINOR_VERS_MISMATCH error to
nfs_errtbl[]. I suppose the only thing we can do is to map it to EIO,
but that would be better than letting it slip through the cracks...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
