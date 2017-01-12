Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59566 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751113AbdALQKM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 11:10:12 -0500
Date: Thu, 12 Jan 2017 11:10:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>, tibbs@math.uh.edu
Subject: Re: RFC: make labeled NFS opt-in
Message-ID: <20170112161005.GA8589@fieldses.org>
References: <20170104165636.GA17649@fieldses.org>
 <20170112021703.GC18977@fieldses.org>
 <CAHVgHyWeGj4GGap8axPnaJYAOBup=LXdeVdQ3fz1o6q7JWkT_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHVgHyWeGj4GGap8axPnaJYAOBup=LXdeVdQ3fz1o6q7JWkT_w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2017 at 10:29:14AM -0500, Andy Adamson wrote:
> NFSv4.2 labeled NFS provides 'guest mode' Mandatory Access Control
> (MAC) where the client can enforce labeling and store a label on the
> server, but the server itself does not enforce the same MAC as the
> client because the client request thread label is unknown to the
> server. RPCSEC_GSS version 3 label assertions asserts the client
> thread label on the NFSD thread handling the request, and so along
> with LNFS provides Full Mode MAC.
> 
> AFAICS the only time we want GSS3 label assertions is if LNFS is
> enabled.  Does this sound right to you? If so, I will use this new per
> export LNFS option to determine when GSS3 label assertions are
> enabled.

How do you disable or enable this on the server side?

I haven't been following the GSS3 development well, apologies.  So I
guess you must do something like:

	1. decode the GSS3 stuff in the RPC layer and store the
	resulting subject label somewhere like rqstp->rq_cred.
	2. in nfsd_setuser, set the nfsd thread's label to the label
	stored in rq_cred.

You probably need to have the processing in step 1 enabled all the time,
because you don't know which export you're going to be dealing with yet
at that point.

By step 2 you have the export.  So I guess you'd use the export option
to decide whether to silently ignore the label, or apply it to the nfsd
thread?

That might make sense.

--b.
