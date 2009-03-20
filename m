From: Steve Dickson <SteveD@redhat.com>
Subject: Re: The next step: nfsvers=4
Date: Fri, 20 Mar 2009 07:55:45 -0400
Message-ID: <49C38441.5060201@RedHat.com>
References: <49C2704F.5050303@RedHat.com> <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com> <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com> <49C28201.1020301@panasas.com> <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com> <49c29203.85c2f10a.098d.17b5@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45549 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbZCTL6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 07:58:37 -0400
In-Reply-To: <49c29203.85c2f10a.098d.17b5-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> 
> I would strongly suggest touching and/or changing as few options as
> possible, and paying close attention to the results with legacy or
> generic configurations on new kernels. The more lenient, the better
> IMO, except where specific options require specific actions.
I agree with this... Being "backwards compatible" is imperative.
And allowing people to configure things to best fit their 
environment is something else we should maintain and possibly 
improve on...

steved.   
