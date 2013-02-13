Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932137Ab3BMAce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 19:32:34 -0500
Message-ID: <511ADF17.4050707@RedHat.com>
Date: Tue, 12 Feb 2013 19:32:23 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Casey Schaufler <casey@schaufler-ca.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <20130212214131.GI10267@fieldses.org> <511ABC09.3040605@schaufler-ca.com>
In-Reply-To: <511ABC09.3040605@schaufler-ca.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/13 17:02, Casey Schaufler wrote:
> On 2/12/2013 1:41 PM, J. Bruce Fields wrote:
>> On Fri, Feb 08, 2013 at 07:39:08AM -0500, Steve Dickson wrote:
>>>  include/linux/security.h            |  57 +++-
>> ...
>>>  security/capability.c               |  19 +-
>>>  security/security.c                 |  24 +-
>>>  security/selinux/hooks.c            |  92 +++++-
>>>  security/selinux/include/security.h |   2 +
>>>  security/selinux/ss/policydb.c      |   5 +-
>>>  security/smack/smack_lsm.c          |  11 +
>>>  33 files changed, 1352 insertions(+), 214 deletions(-)
>> Are we still waiting on ACKs from the security people for these bits?
> 
> I'm not going to NAK it, because I don't know it won't work,
> but I'm not going to ACK it either, because I have not been
> able to get it to work. I have no idea what the problem
> might be, and the "obvious" things we've tried have proven
> ineffective. I may have a bad set of user space tools. There
> may be more work on Smack hooks required. I can't tell, and
> there's way too much NFS set-up involved to make progress in
> the limited time I have available.
Would you please give me an example of what you have not gotten to work?

steved.

> 
> If you're waiting for my ACK, no, you don't have it.
> If you're OK with a lack of NAK, go ahead. There will
> be changes someday I suspect, but I can't put this high
> enough on my priorities to devote the time required
> just now.
> 
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
