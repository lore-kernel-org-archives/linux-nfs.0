Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26990 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab3FEPhV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 11:37:21 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130605112635.188f628e@notabene.brown>
Date: Wed, 5 Jun 2013 11:37:12 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown> <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com> <20130603122319.47f4e0dd@notabene.brown> <0016A272-E433-4020-91FE-45A5EE494296@oracle.com> <20130603130101.4acfe706@notabene.brown> <C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com> <20130604093025.5e467eeb@notabene.brown> <9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com> <2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com> <20130605112635.188f628e@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 4, 2013, at 9:26 PM, NeilBrown <neilb@suse.de> wrote:

> On Tue, 4 Jun 2013 15:16:01 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Jun 3, 2013, at 9:13 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Jun 3, 2013, at 7:30 PM, NeilBrown <neilb@suse.de> wrote:
>>> 
>>>> On Mon, 3 Jun 2013 00:32:54 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>>> 
>>>>> On Jun 2, 2013, at 11:01 PM, NeilBrown <neilb@suse.de> wrote:
>>>>> 
>>>>>> On Sun, 2 Jun 2013 22:45:16 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>> 
>>>>>>> 
>>>>>>> On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:
>>>>>>> 
>>>>>>>> On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
>>>>>>>>> 
>>>>>>>>>> As you probably know, since 3.7 (I think) Linux NFS has explicitly
>>>>>>>>>> asked for machine credentials for certain requests rather than asking
>>>>>>>>>> for root credentials as is previously did.
>>>>>>>>>> This causes a regression for people who don't have any machine
>>>>>>>>>> credentials configured and use "gssd -n".
>>>>>>>>>> 
>>>>>>>>>> I gather this was discussed on the mailing list earlier this year but
>>>>>>>>>> not resolved.
>>>>>>>>> 
>>>>>>>>> It's resolved in 3.10-rc.
>>>>>>>>> 
>>>>>>>>> The kernel will attempt to use krb5i for lease management operations.  If that fails because there is no keytab available, it falls back to using AUTH_SYS.
>>>>>>>> 
>>>>>>>> And if the server refuses to accept AUTH_SYS?
>>>>>>>> 
>>>>>>>> I guess this is commit 79d852bf5e7691dc7 ??
>>>>>>> 
>>>>>>> That's one of the subsequent bug fixes.  The initial change is commit 4edaa308.
>>>>>>> 
>>>>>>>> It seems to say that the server should always accept AUTH_SYS ... is that right?
>>>>>>> 
>>>>>>> If we ever find a server implementation that does not support either Kerberos or AUTH_SYS, we can add another step to the negotiation.
>>>>>>> 
>>>>>>> So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 servers, I haven't found an implementation that does not support AUTH_SYS.  We have found one (FreeBSD) that does not support AUTH_NONE.  We do know that some servers allow administrators to control what security flavors are allowed for lease management.
>>>>>>> 
>>>>>>>> That commit isn't tagged for -stable.
>>>>>>>> So do we still need to make it work for 3.7,3.8,3.9 users?
>>>>>>> 
>>>>>>> There are several commits that would need to be back-ported, starting with commit 4edaa308.  I am not certain they would apply cleanly to 3.[789], but a backport should not be difficult.
>>>>>>> 
>>>>>>> This change also requires that now gssd must be running on the client.  Otherwise without gssd a sec=sys mount hangs for a bit waiting for the upcall to time out (since the client will attempt to use krb5i for lease management operations).  Trond and Bruce have been discussing a change to address that.
>>>>>> 
>>>>>> Thanks for the explanation.  That all looks rather painful to back-port
>>>>>> though, especially as some of it isn't even written yet :-)
>>>>>> I think I'll stick with my "-N" option for openSUSE for now.
>>>>>> 
>>>>>> Do you think that supporting -N (or similar) so that the admin can ask for
>>>>>> root credentials to be used for SETCLIENTID requests is reasonable? i.e. what
>>>>>> do you think of my patch going in to nfs-utils anyway?
>>>>> 
>>>>> So, let me confirm my understanding of your proposed changes: a user logs in as root, then kinit's with her own user principal.  That establishes a Kerberos credential for root to use, and "-N" makes gssd return this credential when the kernel requests "service=*".
>>>> 
>>>> Correct.
>>>> 
>>>>> 
>>>>> Lease management is shared among all NFS users on a client.  In particular, machine credentials give us two important features that cannot be matched by user credentials:
>>>>> 
>>>>> o  Machine credentials never expire even when users log out.  On a
>>>>>   multi-user client, you don't want credential expiry or a user
>>>>>   logout to cause lease management to stop working for other users. 
>>>> 
>>>> ... while on a single-user client, this isn't really an issue.
>>>> 
>>>> And I can easily imagine a server admin not wanting to hand out credentials
>>>> that never expire, but still requiring strong credentials for lease
>>>> management.
>>> 
>>> Why, exactly, would strong credentials be required for lease management, but an admin would choose not to hand out keytabs?
>>> 
>>>> 
>>>>> 
>>>>> o  Machine credentials are always the same no matter who is logged
>>>>>   in.  The client has to use the same credential every time for
>>>>>   lease management, or else servers return CLID_INUSE and prevent a
>>>>>   fresh lease from being established (at least until the existing
>>>>>   lease for that clientid expires on the server).
>>>> 
>>>> Again, not really an issue for a single-user client.  And single-user
>>>> machines are certainly a common use-case these days.
>>>> 
>>>>> 
>>>>> Using root's credentials for lease management makes it likely one of these two bullets will end up in your foot.  Specifically for the use case where one user is always using the same client (say, a student's laptop), "-N" might work fine.  For other use cases, like a shared build machine that doesn't have a keytab, "-N" would not work reliably.
>>>> 
>>>> Completely agree.  So -N should certainly not be the default.
>>>> 
>>>>> 
>>>>> With 3.10, if we can't use a Kerberos host principal for lease management, we'll use a less secure equivalent.  The point of backing off the security flavor for lease management is that AUTH_SYS with UID 0, or even AUTH_NONE, are essentially machine credentials.  They don't expire, and the client will present a consistent credential for lease management, no matter what user logs in or leaves the machine.
>>>>> 
>>>>> So, yes, machine credentials are a pain in the ass, and have been for years.  I'm sorry this took 3 kernel releases to figure out, but I'm hoping that the path we're on with these kernel changes is towards more transparent support for a wider array of use cases.  NFSv4.1 also offers some relief in this area (see SP4_MACH_CRED, which I think we do not support quite yet).
>>>> 
>>>> All sounds very good, but doesn't seem to address the issue.
>>> 
>>>> For the openSUSE user who raised this, he simply does not have a machine
>>>> credential. I don't know why, maybe the server admin doesn't want to hand
>>>> them out.
>>> 
>>> Handing out keytabs for every NFS client that wants to use Kerberized NFS is onerous for some administrators.
>>> 
>>>> But this hasn't been a problem because "gssd -n" meant that a
>>>> machine credential would never be used.
>>> 
>>> No, it meant that root's user credential was used instead of a service credential for lease  management.  As I explained above, that solution has some compromises for some important use cases.
>> 
>> Correction:
>> 
>> rpc.gssd(8) on Fedora 18 says:
>> 
>>> With the -n option, "machine credentials" will not be used for accesses by UID 0.
>> 
>> 
>> In other words, normally root doesn't have a Kerberos ticket.  The kernel uses the machine's credentials for UID 0.  "-n" means only that root has to kinit.
>> 
>> 
>>>> But now,  with 3.[789], "gssd -n" still wants the machine credential that
>>>> doesn't exist.
>>> 
>>> The change that introduced the requirement for a machine credential is commit 68c97153 "SUNRPC: Clean up the RPCSEC_GSS service ticket requests", Tue Jan 3 13:22:46 2012, which was merged long before 3.7.
>>> 
>>> The Uniform Client String changes in 3.7 merely made the machine credential requirement more obtrusive.  The new broken "-n" behavior is an unintended side effect.
>> 
>> I was wondering what exactly about 3.7's UCS changes exposed the requirement for a machine credential, so I built a 3.6 kernel and tried it.
>> 
>> The key difference between 3.6 and 3.7 is that 3.6 performs the SETCLIENTID much later, after a user has logged in and kinit'd, and is actually doing an OPEN.
>> 
>> 3.6 requests a machine credential, but if that fails, it asks for the OPEN user's credential for SETCLIENTID.  The retried upcall request is for "service=<null> UID=nnnn".
>> 
>> If root kinit's for the mount, but the user does not kinit before accessing the mount, the SETCLIENTID still fails!  Root's ticket and "gssd -n" has nothing to do with SETCLIENTID's security flavor, as far as I can tell.
>> 
>> With 3.7, the SETCLIENTID is done right at mount time.  There is no user with credentials trying to do an OPEN, so the only credential the kernel tries is the machine's credential.  Perhaps the kernel could retry the upcall with "server=<null> UID=0".
>> 
>>>> It is possible that with 3.10, he might get away with doing lease management
>>>> with AUTH_SYS, but that seems unlikely.  Given that an integrity protecting
>>>> security flavour is now recommended for SETCLIENTID, his server admin
>>>> could easily make a case that AUTH_SYS won't be accepted.  In that case he
>>>> would still have a problem.
>>> 
>>> His problem then would be with his server admin, not with us.
>>> 
>>> If a server admin wants to protect his server by denying the use of AUTH_SYS for lease management, he has every right to do that.  But he must also therefore understand the position that puts his users in.
>>> 
>>>> Given that "gssd -n" has meant "no machine credential needed" in the past,
>>> 
>>> It never meant that.  It meant "use root's credential as the machine credential".  I think we should be clear about exactly what "-n" is.
>> 
>> Right, I should heed my own words.
>> 
>>> I also believe "-n" (or "-N") is a workaround.  Logging in as root and authenticating is a pain for users, who have already logged in once.
>> 
>> This is still true, however.
>> 
>>>> I think it is important to preserve the possibility of running secure NFS with
>>>> no machine credential.  I don't see how your changes (valuable though they are)
>>>> achieve that.
>>> 
>>> Please explain how allowing lease management to occur using AUTH_SYS is somehow a major new exposure.  A mixture of sec=sys and sec=krb5 mounts today means there's a good chance that a sec=sys mount might occur first, and thus lease management uses AUTH_SYS anyway.
>>> 
>>> Can you share your attack model?  Why do you believe that using AUTH_SYS for lease management on sec=krb5 mounts will be unacceptable to users?  I suspect that most will not notice or care.
>> 
>> I'm still interested in knowing if we have a palpable hole in the current solution in 3.10.
>> 
>>>> So I think we either need to change "gssd -n" to mean "never use machine
>>>> credentials" or add something like "gssd -N", so the two different possible
>>>> uses of machine credentials can be separately controlled.
>>> 
>>> I'm not convinced that "-N" is the right way to fix this.  Another knob to turn means more testing for us, more documentation to write and maintain, and so on.  It doesn't get us any farther forward.  The difference between "-n" (which no longer works) and "-N" is subtle and confusing.  Explaining when to use "-N" versus "-n" is not a job I would like to do, and I'm not interested in taking the support calls either.  :-p
>> 
>> Let me restate this without all the cleverness.
>> 
>> Trond's recommendation was to tell gssd exactly where to find the machine credential if it's not in a keytab: basically an option that says "look in this file for that user credential".  That was our first try, but it was clumsy.
>> 
>> You want "gssd -N" to mean specifically "use root's ticket as the machine credential."  Then "-n -N" would mean "force root to kinit, and use root's ticket as the machine credential."  (Perhaps "-N" doesn't make sense unless "-n" is also specified...?)
>> 
>> But that's still not the same as 3.6's behavior.  And, it would still be a regression, as I understand it, because a user space change would be needed after a kernel upgrade.  For that reason, for 3.[789] we probably want to find a kernel-only solution.
>> 
>> Command line options on gssd are really poor from a usability standpoint.  IMO in the long run we want "mount sec=krb5 without a client keytab" just to work.  No monkeying with gssd.
>> 
> 
> Hi Chuck,
> thanks for you explanations and investigations - they certainly help.
> 
> Let me try to present my perspective.
> 
> The "problem" situation is where the server admin does not want to hand out
> machine credentials (keytabs).
> As you say:
>   "Handing out keytabs for every NFS client that wants to use Kerberized NFS
>    is onerous for some administrators"

We agree that there are environments where no host or nfs service principal is available for clients, and we agree that type of environment should be supported with Linux's NFSv4 client.

Where we differ is what compromises we will accept in that type of environment.

> If I want to use my personal machine to access only my files over NFS then,
> from the server admin's perspective, a kerberos login should be enough.  And
> until recently it has been.

I agree that not supporting this is a bug (regression) and should be fixed.

> This server admin might have read Dave Noveck's recommendations that you
> quote in commit 4edaa308888b:
> 
>    Dave Noveck's migration issues draft recommends the use of an
>    integrity-protecting security flavor for the SETCLIENTID operation.

That's a recommendation, not a requirement.  This means the standards authors (me, being one of the authors on Dave's migration draft) recognize there are legitimate use cases where using an integrity-protecting security flavor is not feasible.

Either the client or the server can enforce the use of an integrity-protecting flavor, but it is also possible that neither do.  (AUTH_NONE and AUTH_SYS-only environments being one important example).

> and decided to disable AUTH_SYS for SETCLIENTID.

Again, I ask: what is being protected?  Why would an administrator make this requirement?  I would like to clearly understand this particular attack so we can design a smart solution that does what administrators want.

> For 3.6 (and earlier?) a client could work with this by running "kinit" as
> both themselves and root, and running "gssd -n".  Then whenever they access
> files, or whenever root accesses files on their behalf, the access uses their
> credential and works.  The only access that tried to use the machine
> credential (which doesn't exist) would be performed in the context of an
> access by the user (an open) and would fall back on the user's credential.
> 
> In 3.[789] the mount doesn't work because it requires a SETCLIENTID which
> tries to use the machine credential and has no user to fall back on.
> It falls back on AUTH_NONE (is that right?) which the server doesn't accept.

The 3.7+ fallback logic works just like 3.6 and earlier.  The difference is that now the SETCLIENTID occurs as the first operation on the first mount.  At that early stage, there are no user credentials available because no-one has attempted to create any open or lock state, which is what is mined on the client for a user credential.

> In 3.10 the same happens but now it falls back on AUTH_SYS and the server
> still doesn't accept it (because Dave said integrity protection is important).

No one has proposed a server change, so AUTH_SYS should be a reasonable choice.  Servers do not have to enforce the use of integrity-protecting security flavors for lease management unless the administrators recognize a palpable threat.  I'm trying to identify what kind of threats that might be, because so far we have been talking in hypotheticals.

> The only way I can see out of this is for the SETCLIENTID request at mount
> time to be able to use root's credential.

That's what the patch I posted does.  If the kernel requests "service=*" and gssd returns -EACCES, the kernel will look for a user credential.  If there are no user credentials to try, it will try "service=<null> UID=0".  If that doesn't work, 3.[789] fail.

I haven't worked out how 3.10+ will behave.  I suspect it could try using the UID=0 principal to establish a client ID using krb5i, and if _that_ fails, then slip back to AUTH_SYS.

> I don't much care whether:
>  a- the kernel requests
>          mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2
>     if
>          mech=krb5 uid=0 service=* enctypes=18,17,16,23,3,1,2
>     fails, or
>  b- gssd tried the credential for 'uid=0' when a lookup for the machine
>     credential fails, or
>  c- "gssd -N" means "use uid=0 credential when kernel requests a machine
>     credential" or
>  d- "gssd -n" adds the above to its current meaning.
> 
> 'c' is what I implemented as it has least impact on people who don't care.
> I think you suggested 'a' above.  I'm certainly happy with that, but I'd
> rather not try to implement it myself.
> I don't particularly need a "kernel-only solution" as I can update nfs-utils
> in openSUSE just as easily as the kernel,

Understood, distributors are lucky in that regard ;-) .  The requirement for a kernel-only solution is for upstream.  Upgrading from 3.6 to 3.7 should not require a user space adjustment like a new command line option or a new version of gssd.

> but it is a good idea in principle
> and I'd be happy to get it tested if someone else implements it :-)

> Your desire to make it "just work" without monkeying around with flags to gssd
> is certainly good.  However there is a key difference between a multi-user
> client and a single-user client.  For the multi-user client there must be a
> separate "root" identity, whether in the form of a machine credential or a
> credential for uid=0.  For the single-user client there is only one identity.
> So somewhere that distinction needs to be configured.

I believe we will be fundamentally better off if we use the same mechanism in both cases.  The implementation is less complex and easier for us to test and maintain.  The promise of a broad "no configuration" solution also has its appeal.

> One way is requiring a 'kinit' as root and running "gssd -n", but that is
> indeed clumsy.
> The only other approach I can think if is a mount option: 'root-uid=NN'
> This would mean that any access that would require a "uid=0" credential
> lookup instead uses a "uid=NN" credential lookup.  That would mean that the
> single user would not need to "kinit" as root.  They just "kinit" as
> themselves and mount the filesystem with the right option and everything
> "just works".

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




