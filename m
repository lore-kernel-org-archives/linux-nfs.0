Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3931 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757826Ab3KHQ1J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 11:27:09 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Date: Fri, 8 Nov 2013 16:27:03 +0000
Message-ID: <10EF251E-CE2B-4761-BBE9-CAFF253610D7@netapp.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>	<527C07B4.800@RedHat.com>
	<44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
	<527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
 <527CFC72.2030907@RedHat.com>
In-Reply-To: <527CFC72.2030907@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 8, 2013, at 10:00 AM, Steve Dickson <SteveD@redhat.com> wrote:

> What server makes krb5i available today in state setup and pseudoroot lookups?

Linux nfsd, among others…

The real issue I see here is what Trond was mentioning earlier - the order of multiple mounts of the same server matters, i.e.:

1) mount sec=krb5i server:/foo /mnt1
2) mount sec=sys server:/foo /mnt2

This leads to the state operations to server using krb5i, but:

1) mount sec=sys server:/foo /mnt2
2) mount sec=krb5i server:/foo /mnt1

this leads to the state operations to server using AUTH_SYS. yuck.

I don’t think we can just upgrade the state connection from AUTH_SYS to krb5i when this happens, that is why we try krb5i first, then fall back to AUTH_SYS.

-dros 

