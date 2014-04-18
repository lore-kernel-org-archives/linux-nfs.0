Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:34537 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139AbaDRQy3 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 12:54:29 -0400
Subject: Re: NFS4ERR_STALE_STATEID from Linux 4.1 server
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Glenn Skinner <gskinner@vmware.com>
In-Reply-To: <20140418090428.GA8156@pad.redhat.com>
Date: Fri, 18 Apr 2014 09:54:28 -0700
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
Message-Id: <2E58AB5D-6AED-449F-959D-BC8D8973417F@vmware.com>
References: <2642778C-2AB4-4709-B2AB-04A0C4F28641@vmware.com> <20140418090428.GA8156@pad.redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See comments in line.

On Apr 18, 2014, at 2:04 AM, J. Bruce Fields wrote:

> Agreed that this sounds like a bug.

Thanks for looking at this.

> a8a7c6776f8d74780348bef639581421d85a4376 "nfsd: Don't return
> NFS4ERR_STALE_STATEID for NFSv4.1+", now in v3.15-rc1, prevents the
> stale_stateid return.  What are the symptoms on your client?  If this
> fixes a practical issue for users then we should probably get that
> backported to stable.

Let me ask a question in turn.  Does your fixed server return NFS4ERR_BAD_STATEID in circumstances where pre-fix it would return NFS4ERR_STALE_STATEID? I ask because (in production versions of ESX, which don't have assertions enabled) we return a lock lost error upward for the former, but an IO error for the latter.  This difference has consequences for higher-level software, such as our FT (fault tolerance) software feature where it will affect decisions on how quickly to fail over to another ESX instance.

For development versions of ESX encountering NFS4ERR_STALE_STATEID triggers an assertion failure, which forces the instance in question to crash.  That has definite practical consequences for our internal development and testing organizations.

> Could you also send this to linux-nfs@vger.kernel.org?  Among other
> things keeping that list cc'd increases the chance that you might still
> get a useful answer at times (like this one) when I'm traveling.

I've added that alias as a CC and have retained the original message below.

> --b.
> 
> On Sat, Apr 12, 2014 at 03:26:20PM -0700, Glenn Skinner wrote:
>> While running stress tests against the VMware NFS v4.1 client, I've seen the Linux server return NFS4ERR_STALE_STATEID a couple times now.  I've tried to catch the server in the act while doing a packet capture, but the behavior occurs rarely enough that so far I've not been able to do so.
>> 
>> According to section 15.1.16.5 of RFC 5661, "this error is moot in NFSv4.1 because all operations that take a stateid MUST be preceded by the SEQUENCE operation, and the earlier server instance is detected by the session infrastructure that supports SEQUENCE".
>> 
>> We have our client set to trigger an assertion failure when it encounters this error.  In debugging the resulting core dump, I've verified that the offending request did start with SEQUENCE and that the server returned NFS4_OK for that operation.
>> 
>> So something seems wrong on the server end.  I was running Fedora 20; uname -a on the server gives:
>> 
>>    Linux proma-1s-dhcp101.eng.vmware.com 3.11.10-301.fc20.x86_64 #1 SMP Thu Dec 5 14:01:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
>> 
>> On the client side I was running the following loop:
>> 
>> # while true; do cp VMware-VMvisor-Installer-6.0.0-00000.x86_64.iso xxx; diff VMware-VMvisor-Installer-6.0.0-00000.x86_64.iso xxx; rm xxx; done
>> 
>> (VMware-VMvisor-Installer-6.0.0-00000.x86_64.iso is a rather large file.)
>> 
>> On the server side I was running:
>> 
>> # while true; do systemctl restart nfs; sleep 10; done
>> 
>> I had v2 and v3 disabled:
>> 
>> # cat /proc/fs/nfsd/versions
>> -2 -3 +4 +4.1-4.2
>> #
>> 
>> Does this server behavior ring any bells?  Might it have something to do with straight version 4 being enabled along with 4.1?  (And is there any way to disable version 4.0 while leaving 4.1 enabled?)


		-- Glenn

