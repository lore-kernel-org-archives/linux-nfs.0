Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757248Ab3KHQhN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 11:37:13 -0500
Message-ID: <527D1372.20001@RedHat.com>
Date: Fri, 08 Nov 2013 11:38:10 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>	<527C07B4.800@RedHat.com>	<44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>	<527CDBFC.3070903@RedHat.com> <20131108082202.4032f1a2@tlielax.poochiereds.net> <527CFC72.2030907@RedHat.com> <10EF251E-CE2B-4761-BBE9-CAFF253610D7@netapp.com>
In-Reply-To: <10EF251E-CE2B-4761-BBE9-CAFF253610D7@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/11/13 11:27, Weston Andros Adamson wrote:
> 
> On Nov 8, 2013, at 10:00 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> What server makes krb5i available today in state setup and pseudoroot lookups?
> 
> Linux nfsd, among others…
> 
> The real issue I see here is what Trond was mentioning earlier - the order of multiple mounts of the same server matters, i.e.:
> 
> 1) mount sec=krb5i server:/foo /mnt1
> 2) mount sec=sys server:/foo /mnt2
> 
> This leads to the state operations to server using krb5i, but:
> 
> 1) mount sec=sys server:/foo /mnt2
> 2) mount sec=krb5i server:/foo /mnt1
> 
> this leads to the state operations to server using AUTH_SYS. yuck.
> 
> I don’t think we can just upgrade the state connection from AUTH_SYS to krb5i 
> when this happens, that is why we try krb5i first, then fall back to AUTH_SYS.

Excellent explanation! Thanks you! But... ;-) This assumes the admin is
actually trying to krb5i which means he/she has set up a functioning 
Kerberos environment. But we can't assume every client has a valid 
Kerberos environment, which is what the code is doing today!

steved.

