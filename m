Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:28814 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538Ab3FCCpQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jun 2013 22:45:16 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130603122319.47f4e0dd@notabene.brown>
Date: Sun, 2 Jun 2013 22:45:16 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown> <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com> <20130603122319.47f4e0dd@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:

> On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
>> 
>>> As you probably know, since 3.7 (I think) Linux NFS has explicitly
>>> asked for machine credentials for certain requests rather than asking
>>> for root credentials as is previously did.
>>> This causes a regression for people who don't have any machine
>>> credentials configured and use "gssd -n".
>>> 
>>> I gather this was discussed on the mailing list earlier this year but
>>> not resolved.
>> 
>> It's resolved in 3.10-rc.
>> 
>> The kernel will attempt to use krb5i for lease management operations.  If that fails because there is no keytab available, it falls back to using AUTH_SYS.
> 
> And if the server refuses to accept AUTH_SYS?
> 
> I guess this is commit 79d852bf5e7691dc7 ??

That's one of the subsequent bug fixes.  The initial change is commit 4edaa308.

> It seems to say that the server should always accept AUTH_SYS ... is that right?

If we ever find a server implementation that does not support either Kerberos or AUTH_SYS, we can add another step to the negotiation.

So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 servers, I haven't found an implementation that does not support AUTH_SYS.  We have found one (FreeBSD) that does not support AUTH_NONE.  We do know that some servers allow administrators to control what security flavors are allowed for lease management.

> That commit isn't tagged for -stable.
> So do we still need to make it work for 3.7,3.8,3.9 users?

There are several commits that would need to be back-ported, starting with commit 4edaa308.  I am not certain they would apply cleanly to 3.[789], but a backport should not be difficult.

This change also requires that now gssd must be running on the client.  Otherwise without gssd a sec=sys mount hangs for a bit waiting for the upcall to time out (since the client will attempt to use krb5i for lease management operations).  Trond and Bruce have been discussing a change to address that.

> Thanks,
> NeilBrown
> 
>> 
>> 
>>> I would like to re-awaken the issue and offer a resolution (which has
>>> been tested and found effective by a customer).
>>> 
>>> Hence these three patches.  The first two are minor issues that I
>>> stumbled over while trying to understand the problem and are not
>>> critical but probably should be fixed.
>>> 
>>> The third addresses the above mentioned issue.  It introduces a
>>> variable "machine_uses_root_credentials" which is similar to the
>>> current "root_uses_machine_credentials".  It also adds a "-N" flag to
>>> set this variable.
>>> 
>>> I'm not certain what the defaults should be.  For backward
>>> compatibility it would be best if '-n' set the this new variable as
>>> well as clearing the old one, but then I'm not sure what exactly -N
>>> should do.
>>> 
>>> Comments welcome.
>>> 
>>> Thanks,
>>> NeilBrown
>>> 
>>> 
>>> 
>>> ---
>>> 
>>> Neil Brown (3):
>>>     krb5_utils: remove redundant array size.
>>>     krb5_util: don't give up on machine credential if hostname not available.
>>>     gssd: add -N option to use root credentials as machine credentials.
>>> 
>>> 
>>> utils/gssd/gssd.c      |    9 ++++++---
>>> utils/gssd/gssd.h      |    1 +
>>> utils/gssd/gssd.man    |   13 ++++++++++++-
>>> utils/gssd/gssd_proc.c |   12 +++++++-----
>>> utils/gssd/krb5_util.c |   10 +++++++---
>>> 5 files changed, 33 insertions(+), 12 deletions(-)
>>> 
>>> -- 
>>> Signature
>>> 
>> 
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



