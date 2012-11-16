Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:40749 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750812Ab2KPDoA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 22:44:00 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Thu, 15 Nov 2012 22:43:57 -0500
From: David Quigley <dpquigl@davequigley.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        "David P. Quigley" <selinux@davequigley.com>,
        <trond.myklebust@netapp.com>, <sds@tycho.nsa.gov>,
        <linux-nfs@vger.kernel.org>, <selinux@tycho.nsa.gov>,
        <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <50A5B441.70206@schaufler-ca.com>
References: <50A116F0.5050404@davequigley.com>
 <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com>
 <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com>
 <50A31EF5.1050801@davequigley.com> <20121114134535.GD23604@fieldses.org>
 <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net>
 <20121114135939.GE23604@fieldses.org>
 <80f36fef2a58eb538bce28daba3a862a@countercultured.net>
 <20121114142458.GF23604@fieldses.org>
 <4f9b24e3942b4a28cd9068d5bc0135fa@countercultured.net>
 <50A51195.9080004@schaufler-ca.com>
 <a843eae7d5fa2df4faa99bf5531dcecc@countercultured.net>
 <50A5B441.70206@schaufler-ca.com>
Message-ID: <98ae8bfde2b1967c7db6db1f04ce73b1@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2012 22:34, Casey Schaufler wrote:
> On 11/15/2012 12:28 PM, David Quigley wrote:
>> On 11/15/2012 11:00, Casey Schaufler wrote:
>>> On 11/14/2012 6:30 AM, David Quigley wrote:
>>>> On 11/14/2012 09:24, J. Bruce Fields wrote:
>>>>> On Wed, Nov 14, 2012 at 09:04:18AM -0500, David Quigley wrote:
>>>>>> On 11/14/2012 08:59, J. Bruce Fields wrote:
>>>>>> >On Wed, Nov 14, 2012 at 08:50:17AM -0500, David Quigley wrote:
>>>>>> >>On 11/14/2012 08:45, J. Bruce Fields wrote:
>>>>>> >>>On Tue, Nov 13, 2012 at 11:32:53PM -0500, Dave Quigley wrote:
>>>>>> >>>>Ok so if you go to http://www.selinuxproject.org/git you 
>>>>>> will
>>>>>> >>see a
>>>>>> >>>>repo for lnfs and lnfs-patchset. The instructions at
>>>>>> >>>>http://www.selinuxproject.org/page/Labeled_NFS give you a 
>>>>>> better
>>>>>> >>>>indication on how to pull the trees. I've attached a patch 
>>>>>> for
>>>>>> NFS
>>>>>> >>>>utils which gives support for 
>>>>>> security_label/nosecurity_label in
>>>>>> >>>>your /etc/exports file.
>>>>>> >>>
>>>>>> >>>Do we need an export option?  Is there any reason not to make 
>>>>>> the
>>>>>> >>>feature available whenever there's support available for it?
>>>>>> >>
>>>>>> >>I guess we could build it in but I figured an export option 
>>>>>> allowed
>>>>>> >>someone to turn off security labeling support if they didn't
>>>>>> want it
>>>>>> >>on that export. What happens to clients when the server 
>>>>>> returns a
>>>>>> >>cap that they don't support? Do they mask the bits out?
>>>>>> >
>>>>>> >Yeah, they should just ignore it.
>>>>>> >
>>>>>> >While this is still experimental it's still nice to have a way 
>>>>>> to
>>>>>> >turn
>>>>>> >this on and off at runtime so people can experiment without
>>>>>> having to
>>>>>> >have it on for everyone all the time.  But
>>>>>> >nfsd_supported_minorversion
>>>>>> >should be sufficient for that.
>>>>>> >
>>>>>> >(I don't think your patches actually dealt yet with the fact 
>>>>>> that
>>>>>> >this
>>>>>> >is part of minor version 2?  Another for the todo list.)
>>>>>> >
>>>>>> >--b.
>>>>>>
>>>>>> If we use nfsd_supported_minorversion which I'm guessing is an
>>>>>> export option
>>>>>
>>>>> That's just a variable in the code.  It's controlled by
>>>>> /proc/fs/nfsd/versions.
>>>>>
>>>>>> what happens if someone wants to use other 4.2
>>>>>> features but not labeling?
>>>>>
>>>>> We'll cross that bridge when we come to it, maybe by adding some 
>>>>> new
>>>>> global paramater.
>>>>>
>>>>> There's no reason this really needs to be per-export, is there?
>>>>>
>>>>> --b.
>>>>
>>>> At the moment I can't really think of a reason to have it be
>>>> per-export. I think we need a new LSM patch though to determine if 
>>>> the
>>>> LSM supports labeling over NFS unless Steve can think of a better 
>>>> way
>>>> to tell if the LSM supports labeling.
>>>
>>> If the LSM has a secid_to_secctx hook it supports labeling.
>>> Today that's SELinux and Smack. You already have support in
>>> for SELinux, and providing Smack's review and possibly updates
>>> is #2 on my gotta do list. On the whole, I think that, except
>>> for the fundamental philosophical difference between label
>>> support and xattr support, it should be a simple matter to
>>> get support in for any LSM that has secid_to_secctx.
>>>
>>> But I'm still working on the review.
>>>
>>
>> I believe SMACK already works out of the box since we abstracted the
>> call to obtain labels and your implementation currently works.
>
> I'm looking to do a little verification. I hate assuming that 
> something
> will work only to discover otherwise in the wild.
>
>> The call that is needed is not secid_to_secctx but inode_getsecctx.
>
> I was pointing out that secid_to_secctx pretty well defines that the 
> LSM
> is using labels.
>
>> You asked for this because SMACK labels can span multiple xattrs. I
>> don't think its right to expect NFS to poke around the security
>> structure to check if there is a valid hook(and it isn't really
>> possible either).
>
> Yeah, I can see that.
>
>> Maybe we can have an LSM hook where the LSM categorizes itself and
>> returns a value and if the value it returns is label based then NFS
>> can use it.
>
> I'm not sure what the proposed hook would be for except to identify 
> it
> as concerned with nfs. Perhaps the hook could return the names of
> attributes that it wants nfs to provide.
>

I'm not quite sure what you're proposing? I'm sure someone would find 
another use for this hook though. The inode_getsecctx hook we made for 
Labeled NFS was already merged because it was needed for providing 
"persistent" label support for sysfs (meaning that it persisted inode 
eviction from memory). The problem is that we have no real way to ask in 
the NFS code if this is an LSM that can be used with Labeled NFS. In the 
xattr code we have the new ismaclabel hook we add which allows us to 
verify the xattr used as belonging to a label based LSM however we need 
an xattr from userspace for that. The reason this is required is that 
the server will need to fill out its capability mask to indicate it 
supports security labeling. In addition the client also needs to know if 
its running a security label based LSM because it will need to mask out 
the label fattr bit from its getattr calls if it doesn't support it. We 
can override this in SELinux by giving it a context mount but if we 
don't then it will need to know whether or not to be pulling security 
labels back.

