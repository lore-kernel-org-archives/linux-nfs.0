From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 1/4] knfsd: Replace lock_kernel with a mutex for nfsd
 thread startup/shutdown locking.
Date: Fri, 06 Jun 2008 09:35:51 +1000
Message-ID: <48487857.4030706@melbourne.sgi.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>	<1212591796-22144-2-git-send-email-jlayton@redhat.com>	<484737A9.508@melbourne.sgi.com> <20080605200358.GB5829@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:58177 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753526AbYFEXjn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 19:39:43 -0400
In-Reply-To: <20080605200358.GB5829@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Jun 05, 2008 at 10:47:37AM +1000, Greg Banks wrote:
>   
>> I notice there's no change to write_leasetime().  That calls
>> nfs4_reset_lease(), which seems to want to only be called when nfsd is
>> not started (according to my reading of the comment preceding the
>> function), and which uses the BKL to protect the variable
>> user_lease_time.  Perhaps that path should be changed to use the new
>> nfsd_mutex also?
>>     
>
> write_leasetime() just results in setting the user_lease_time, which is
> copied (once, on server startup) to lease_time, which is what is
> actually used by the running server.
Yes, understood.
>   So I don't think there's a race
> here (and the existing BKL use in write_leasetime() isn't really
> needed).
>   
The race is pretty harmless.  The only read of user_lease_time happens
during the critical section currently guarded by the BKL in nfsd_svc();
the only write of the variable is not guarded by that lock.  If you call
write_leasetime() many times with different values during nfsd startup,
the actual value used is not predictable and you can't tell from
userspace whether your write() succeeded in changing the behaviour of
the server or not.  Also, you can do write_leasetime() after nfsd
startup without useful effect; other parameters which can't be changed
from /proc after the service is running will fail the write() with EBUSY.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

