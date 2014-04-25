Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:39537 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751144AbaDYPnM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 11:43:12 -0400
Subject: Re: NFS4ERR_STALE_STATEID from Linux 4.1 server
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Glenn Skinner <gskinner@vmware.com>
In-Reply-To: <20140425090158.GC2347@pad.redhat.com>
Date: Fri, 25 Apr 2014 08:43:12 -0700
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
Message-Id: <9A1C2C2C-E1D6-46F6-8225-F5B95976CC2C@vmware.com>
References: <2642778C-2AB4-4709-B2AB-04A0C4F28641@vmware.com> <20140418090428.GA8156@pad.redhat.com> <2E58AB5D-6AED-449F-959D-BC8D8973417F@vmware.com> <20140425090158.GC2347@pad.redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2014, at 2:01 AM, J. Bruce Fields wrote:

> On Fri, Apr 18, 2014 at 09:54:28AM -0700, Glenn Skinner wrote:
>> See comments in line.
>> 
>> On Apr 18, 2014, at 2:04 AM, J. Bruce Fields wrote:
>> 
>>> Agreed that this sounds like a bug.
>> 
>> Thanks for looking at this.
>> 
>>> a8a7c6776f8d74780348bef639581421d85a4376 "nfsd: Don't return
>>> NFS4ERR_STALE_STATEID for NFSv4.1+", now in v3.15-rc1, prevents the
>>> stale_stateid return.  What are the symptoms on your client?  If this
>>> fixes a practical issue for users then we should probably get that
>>> backported to stable.
>> 
>> Let me ask a question in turn.  Does your fixed server return NFS4ERR_BAD_STATEID in circumstances where pre-fix it would return NFS4ERR_STALE_STATEID?
> 
> Right.

Makes sense.  Just wanted to confirm.

>> I ask because (in production versions of ESX, which don't have assertions enabled) we return a lock lost error upward for the former, but an IO error for the latter.  This difference has consequences for higher-level software, such as our FT (fault tolerance) software feature where it will affect decisions on how quickly to fail over to another ESX instance.
>> 
>> For development versions of ESX encountering NFS4ERR_STALE_STATEID triggers an assertion failure, which forces the instance in question to crash.  That has definite practical consequences for our internal development and testing organizations.
> 
> So, our "fixed server" behavior is an improvement as far as your client
> is concerned?

Yes, it is.  Thanks for fixing this bug.

		-- Glenn

