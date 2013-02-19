Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:47504 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab3BSALG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 19:11:06 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235D18B2@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 18 Feb 2013 19:10:54 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <14355BBE-3126-4F26-A419-6B6434416A8A@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <73594034-4F9D-4DA6-A979-1E2745BCDF05@oracle.com> <CFDAB21B-48E2-4567-A579-DEB6BC77890F@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9235D18B2@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 6:14 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-02-18 at 17:48 -0500, Chuck Lever wrote:
>> On Feb 18, 2013, at 4:16 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Feb 13, 2013, at 10:29 AM, Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>>> 
>>>> I've been using kerberized nfs4 mounts without machine credentials for 
>>>> quite some time by running rpc.gssd with the -n option. This has 
>>>> resulted rpc.gssd in using ccache in /tmp/krb5cc_0 when doing the mount 
>>>> instead of machine credentials. This functionality seems to break when 
>>>> using kernel 3.7 or newer. 3.6.11 and earlier work like expected.
>>>> 
>>>> The use case for this is diskless workstations that do not have machine 
>>>> credentials stored on them as they have no secure storage medium. When a 
>>>> user logs in, the home directory is mounted using the user's credentials 
>>>> only.
>>>> 
>>>> Steps to reproduce the problem:
>>>> 
>>>> # kinit user (this creates /tmp/krb5cc_0)
>>>> # rpc.gssd -f -n -vvvv
>>>> # mount -t nfs4 -o sec=krb5 server.example.org:/home /mnt
>>>> 
>>>> The mount works when using kernel 3.6.11 or earlier and fails on 3.7-rc1 
>>>> or later. Testing was done on Ubuntu 12.04 and 12.10 using Ubuntu kernels
>>>> and kernel.org kernels (up to 3.8-rc7) with similar results.
>>>> 
>>>> nfs-utils versions 1.2.5 and the latest version from git master head 
>>>> (git://linux-nfs.org/nfs-utils) behave the same way.
>>> 
>>> Reproduced.  Not clear yet if this is a kernel regression or a latent gssd bug.
>> 
>> With pre-3.7 kernels, kernel upcalls with "service=<null>" because the first operation is a LOOKUP_ROOT, and a machine credential is not needed.  With 3.7, kernel is upcalling to get a context to perform SETCLIENTID, and it's specifying "service='*'" as a way to get machine credentials.
>> 
>> In the case where there is no keytab and rpc.gssd is invoked with "-n", gssd is trying to use /etc/krb5.keytab anyway, and failing.
>> 
>> "man rpc.gssd" says this about "-n":
>> 
>>> By default, rpc.gssd treats accesses by the user with UID 0  specially,
>>> and  uses  "machine  credentials"  for  all accesses by that user which
>>> require Kerberos authentication.  With the -n option, "machine  creden‐
>>> tials"  will  not  be used for accesses by UID 0.  Instead, credentials
>>> must be obtained manually like all other users.   Use  of  this  option
>>> means  that  "root"  must  manually  obtain Kerberos credentials before
>>> attempting to mount an nfs filesystem  requiring  Kerberos  authentica‐
>>> tion.
>> 
>> It seems to me that if the kernel asks for "service='*'" and gssd was invoked with "-n", gssd should retrieve the manually-obtained Kerberos credentials in that case.
> 
> Why? That is not what the documentation above says. As I read it, the
> documentation states that accesses by uid _0_ will no longer use machine
> creds. It says nothing about accesses that actually request the use of
> machine creds, such as NFSv4 state ownership...

True, it doesn't, and the use of passive voice makes it easy for a reader to conflate the use of machine cred and UID 0.  But this:

> "root" must manually obtain Kerberos credentials before attempting to mount an nfs filesystem requiring Kerberos authentication.


Sure sounds to me like the use case that Veli-Matti presented is supposed to work by becoming root, kinit'ing, then mounting.

We should make the man page more clear.  It would be especially helpful to describe what "machine credentials" are, and how to set up a machine that doesn't have a host key.  Or if there already is such an explanation, a citation in the man page would be nice.

> 
>> I'm staring at process_krb5_upcall(), just past that big block comment around line 962.  I think that logic is probably wrong to check for "service_name==NULL" but should rather check that the service_name is not "nfs".  This a fix that Veli-Matti hinted at earlier.
>> 
>> Thoughts?
> 
> Just blindly changing the meaning of '-n' would be wrong IMO. The whole
> point of adding the new "v1" upcall was to enable the kernel to be
> specific about when it requires machine credentials so that we could
> avoid the whole auth(machine)==auth(root) brain-damage.

So, we agree that the 3.7 kernel is operating as expected, and that gssd should be behaving differently in this case.  Maybe not an outright bug, but a change is needed.

> Note that the old behaviour can be re-enabled by using a version of
> rpc.gssd that only supports the 'v0' upcall. So one alternative might be
> to simply add an option to rpc.gssd that turns off 'v1' upcall support.
> 
> Another, more future-proof alternative, may be to have rpc.gssd
> substitute a user cred if there are no machine creds, and _if_ the admin
> enables an option that specifies exactly which credential file should be
> used.

gssd already has "-k" to specify a different keytab.  "-k /tmp/krb5cc_0" seems easy enough.

Should we simply add another command line option that specifies an additional entry in the machine credentials search order?

root/<hostname>@<REALM> is already in that list, for example.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




