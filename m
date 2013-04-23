Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755534Ab3DWS5F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:57:05 -0400
Message-ID: <5176D97C.7050609@RedHat.com>
Date: Tue, 23 Apr 2013 14:57:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/19] lnfs: 3.9-rc5 release
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>  <20130410150940.GB24404@pad.fieldses.org> <5176ACE5.2020207@RedHat.com>  <20130423160520.GE20622@pad.fieldses.org>  <20130423172227.GF20622@pad.fieldses.org> <5176CD42.4080405@RedHat.com> <1366742457.31304.545.camel@falcor1.watson.ibm.com>
In-Reply-To: <1366742457.31304.545.camel@falcor1.watson.ibm.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 23/04/13 14:40, Mimi Zohar wrote:
> On Tue, 2013-04-23 at 14:04 -0400, Steve Dickson wrote:
>> On 23/04/13 13:22, J. Bruce Fields wrote:
>>>>> What exactly was failing?
>>>>>
>>>>> Sorry I can't find the results right now.  I'll re-run and let you know.
>>> The server is returning -EOPNOTSUPP in response to an nfs4 SETATTR which
>>> sets a mode.
>>>
>>> The operation shouldn't be failing, and if it does it should return an
>>> NFS error, not -ERRNO.
>>>
>>> I can't reproduce this just by doing chmod on the linux client.  I'm not
>>> sure what pynfs is doing differently to trigger the bug.
>> thanks for talking a look...  
>>
>> Hmm... I wonder if the fact nfsd4_set_nfs4_label() is returning 
>> -EOPNOTSUPP instead of something like nfserr_attrnotsupp when 
>> labels are not configured... Something you've pointed out 
>> twice now... 
>>     http://www.spinics.net/lists/linux-nfs/msg36104.html
>>
>> If it is this problem I wonder why a chmod would not trigger it...
> 
> Do you by any chance have EVM enabled?  EVM includes the i_mode in the
> HMAC calculation.  Anytime the i_mode changes, the existing HMAC is
> verified, before recalculating the HMAC to reflect the change.  The
> hooks are there to update the HMAC, when using chmod.
No. CONFIG_EVM is not set.

steved.

> 
> I posted a couple of patches to audit this type of error last week, but
> haven't sent a pull request yet.
> 
> evm: audit integrity metadata failures
> integrity: move integrity_audit_msg()
> evm: calculate HMAC after initializing posix acl
> 
> thanks,
> 
> Mimi
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
