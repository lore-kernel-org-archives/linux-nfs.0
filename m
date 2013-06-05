Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:18322 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432Ab3FEROJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 13:14:09 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
Date: Wed, 5 Jun 2013 13:14:00 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <675A79B3-FA0F-4014-85DA-67CE90E933B2@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown> <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com> <20130603122319.47f4e0dd@notabene.brown> <0016A272-E433-4020-91FE-45A5EE494296@oracle.com> <20130603130101.4acfe706@notabene.brown> <C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com> <20130604093025.5e467eeb@notabene.brown> <9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com> <2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com> <20130605112635.188f628e@notabene.brown> <1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 5, 2013, at 11:37 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 4, 2013, at 9:26 PM, NeilBrown <neilb@suse.de> wrote:
>> 
>> Hi Chuck,
>> thanks for you explanations and investigations - they certainly help.
>> 
>> Let me try to present my perspective.
>> 
>> The "problem" situation is where the server admin does not want to hand out
>> machine credentials (keytabs).
>> As you say:
>>  "Handing out keytabs for every NFS client that wants to use Kerberized NFS
>>   is onerous for some administrators"
> 
> We agree that there are environments where no host or nfs service principal is available for clients, and we agree that type of environment should be supported with Linux's NFSv4 client.
> 
> Where we differ is what compromises we will accept in that type of environment.
> 
>> If I want to use my personal machine to access only my files over NFS then,
>> from the server admin's perspective, a kerberos login should be enough.  And
>> until recently it has been.
> 
> I agree that not supporting this is a bug (regression) and should be fixed.
> 
>> This server admin might have read Dave Noveck's recommendations that you
>> quote in commit 4edaa308888b:
>> 
>>   Dave Noveck's migration issues draft recommends the use of an
>>   integrity-protecting security flavor for the SETCLIENTID operation.
> 
> That's a recommendation, not a requirement.  This means the standards authors (me, being one of the authors on Dave's migration draft) recognize there are legitimate use cases where using an integrity-protecting security flavor is not feasible.
> 
> Either the client or the server can enforce the use of an integrity-protecting flavor, but it is also possible that neither do.  (AUTH_NONE and AUTH_SYS-only environments being one important example).
> 
>> and decided to disable AUTH_SYS for SETCLIENTID.
> 
> Again, I ask: what is being protected?  Why would an administrator make this requirement?  I would like to clearly understand this particular attack so we can design a smart solution that does what administrators want.
> 
>> For 3.6 (and earlier?) a client could work with this by running "kinit" as
>> both themselves and root, and running "gssd -n".  Then whenever they access
>> files, or whenever root accesses files on their behalf, the access uses their
>> credential and works.  The only access that tried to use the machine
>> credential (which doesn't exist) would be performed in the context of an
>> access by the user (an open) and would fall back on the user's credential.
>> 
>> In 3.[789] the mount doesn't work because it requires a SETCLIENTID which
>> tries to use the machine credential and has no user to fall back on.
>> It falls back on AUTH_NONE (is that right?) which the server doesn't accept.
> 
> The 3.7+ fallback logic works just like 3.6 and earlier.  The difference is that now the SETCLIENTID occurs as the first operation on the first mount.  At that early stage, there are no user credentials available because no-one has attempted to create any open or lock state, which is what is mined on the client for a user credential.
> 
>> In 3.10 the same happens but now it falls back on AUTH_SYS and the server
>> still doesn't accept it (because Dave said integrity protection is important).
> 
> No one has proposed a server change, so AUTH_SYS should be a reasonable choice.  Servers do not have to enforce the use of integrity-protecting security flavors for lease management unless the administrators recognize a palpable threat.  I'm trying to identify what kind of threats that might be, because so far we have been talking in hypotheticals.
> 
>> The only way I can see out of this is for the SETCLIENTID request at mount
>> time to be able to use root's credential.
> 
> That's what the patch I posted does.  If the kernel requests "service=*" and gssd returns -EACCES, the kernel will look for a user credential.  If there are no user credentials to try, it will try "service=<null> UID=0".  If that doesn't work, 3.[789] fail.
> 
> I haven't worked out how 3.10+ will behave.  I suspect it could try using the UID=0 principal to establish a client ID using krb5i, and if _that_ fails, then slip back to AUTH_SYS.
> 
>> I don't much care whether:
>> a- the kernel requests
>>         mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2
>>    if
>>         mech=krb5 uid=0 service=* enctypes=18,17,16,23,3,1,2
>>    fails, or
>> b- gssd tried the credential for 'uid=0' when a lookup for the machine
>>    credential fails, or
>> c- "gssd -N" means "use uid=0 credential when kernel requests a machine
>>    credential" or
>> d- "gssd -n" adds the above to its current meaning.
>> 
>> 'c' is what I implemented as it has least impact on people who don't care.
>> I think you suggested 'a' above.  I'm certainly happy with that, but I'd
>> rather not try to implement it myself.
>> I don't particularly need a "kernel-only solution" as I can update nfs-utils
>> in openSUSE just as easily as the kernel,
> 
> Understood, distributors are lucky in that regard ;-) .  The requirement for a kernel-only solution is for upstream.  Upgrading from 3.6 to 3.7 should not require a user space adjustment like a new command line option or a new version of gssd.

In terms of providing fixes for this issue:

  o  3.7.y and 3.8.y are now EOL.  I think I should at least post patches here for these kernels so a fix is available for distributions that continue to rely on these kernel versions

  o  3.9.y is still maintained.  The 3.7 fix I posted yesterday will need to be ported, but I'm guessing that it will work for 3.9 without a lot of alteration

  o  A fix for 3.10-rc will need some adjustment, since there is a significant change in that kernel to use krb5i when possible for lease management operations.  Or, should we consider not applying this fix to upstream?  Would Greg take a fix for 3.9.y that hasn't gone into the upstream kernels?

Thoughts?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



