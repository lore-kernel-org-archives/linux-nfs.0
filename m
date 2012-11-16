Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp107.biz.mail.gq1.yahoo.com ([98.137.12.182]:43025 "HELO
	smtp107.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750812Ab2KPDkx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 22:40:53 -0500
Message-ID: <50A5B441.70206@schaufler-ca.com>
Date: Thu, 15 Nov 2012 19:34:25 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        "David P. Quigley" <selinux@davequigley.com>,
        trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <50A116F0.5050404@davequigley.com> <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com> <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com> <50A31EF5.1050801@davequigley.com> <20121114134535.GD23604@fieldses.org> <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net> <20121114135939.GE23604@fieldses.org> <80f36fef2a58eb538bce28daba3a862a@countercultured.net> <20121114142458.GF23604@fieldses.org> <4f9b24e3942b4a28cd9068d5bc0135fa@countercultured.net> <50A51195.9080004@schaufler-ca.com> <a843eae7d5fa2df4faa99bf5531dcecc@countercultured.net>
In-Reply-To: <a843eae7d5fa2df4faa99bf5531dcecc@countercultured.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2012 12:28 PM, David Quigley wrote:
> On 11/15/2012 11:00, Casey Schaufler wrote:
>> On 11/14/2012 6:30 AM, David Quigley wrote:
>>> On 11/14/2012 09:24, J. Bruce Fields wrote:
>>>> On Wed, Nov 14, 2012 at 09:04:18AM -0500, David Quigley wrote:
>>>>> On 11/14/2012 08:59, J. Bruce Fields wrote:
>>>>> >On Wed, Nov 14, 2012 at 08:50:17AM -0500, David Quigley wrote:
>>>>> >>On 11/14/2012 08:45, J. Bruce Fields wrote:
>>>>> >>>On Tue, Nov 13, 2012 at 11:32:53PM -0500, Dave Quigley wrote:
>>>>> >>>>Ok so if you go to http://www.selinuxproject.org/git you will
>>>>> >>see a
>>>>> >>>>repo for lnfs and lnfs-patchset. The instructions at
>>>>> >>>>http://www.selinuxproject.org/page/Labeled_NFS give you a better
>>>>> >>>>indication on how to pull the trees. I've attached a patch for
>>>>> NFS
>>>>> >>>>utils which gives support for security_label/nosecurity_label in
>>>>> >>>>your /etc/exports file.
>>>>> >>>
>>>>> >>>Do we need an export option?  Is there any reason not to make the
>>>>> >>>feature available whenever there's support available for it?
>>>>> >>
>>>>> >>I guess we could build it in but I figured an export option allowed
>>>>> >>someone to turn off security labeling support if they didn't
>>>>> want it
>>>>> >>on that export. What happens to clients when the server returns a
>>>>> >>cap that they don't support? Do they mask the bits out?
>>>>> >
>>>>> >Yeah, they should just ignore it.
>>>>> >
>>>>> >While this is still experimental it's still nice to have a way to
>>>>> >turn
>>>>> >this on and off at runtime so people can experiment without
>>>>> having to
>>>>> >have it on for everyone all the time.  But
>>>>> >nfsd_supported_minorversion
>>>>> >should be sufficient for that.
>>>>> >
>>>>> >(I don't think your patches actually dealt yet with the fact that
>>>>> >this
>>>>> >is part of minor version 2?  Another for the todo list.)
>>>>> >
>>>>> >--b.
>>>>>
>>>>> If we use nfsd_supported_minorversion which I'm guessing is an
>>>>> export option
>>>>
>>>> That's just a variable in the code.  It's controlled by
>>>> /proc/fs/nfsd/versions.
>>>>
>>>>> what happens if someone wants to use other 4.2
>>>>> features but not labeling?
>>>>
>>>> We'll cross that bridge when we come to it, maybe by adding some new
>>>> global paramater.
>>>>
>>>> There's no reason this really needs to be per-export, is there?
>>>>
>>>> --b.
>>>
>>> At the moment I can't really think of a reason to have it be
>>> per-export. I think we need a new LSM patch though to determine if the
>>> LSM supports labeling over NFS unless Steve can think of a better way
>>> to tell if the LSM supports labeling.
>>
>> If the LSM has a secid_to_secctx hook it supports labeling.
>> Today that's SELinux and Smack. You already have support in
>> for SELinux, and providing Smack's review and possibly updates
>> is #2 on my gotta do list. On the whole, I think that, except
>> for the fundamental philosophical difference between label
>> support and xattr support, it should be a simple matter to
>> get support in for any LSM that has secid_to_secctx.
>>
>> But I'm still working on the review.
>>
>
> I believe SMACK already works out of the box since we abstracted the
> call to obtain labels and your implementation currently works.

I'm looking to do a little verification. I hate assuming that something
will work only to discover otherwise in the wild.

> The call that is needed is not secid_to_secctx but inode_getsecctx.

I was pointing out that secid_to_secctx pretty well defines that the LSM
is using labels.

> You asked for this because SMACK labels can span multiple xattrs. I
> don't think its right to expect NFS to poke around the security
> structure to check if there is a valid hook(and it isn't really
> possible either).

Yeah, I can see that.

> Maybe we can have an LSM hook where the LSM categorizes itself and
> returns a value and if the value it returns is label based then NFS
> can use it.

I'm not sure what the proposed hook would be for except to identify it
as concerned with nfs. Perhaps the hook could return the names of
attributes that it wants nfs to provide.


>
>>>
>>>
>>>>
>>>>> I'll switch it over if you guys want it
>>>>> done that way, I think though that this provides more flexibility.
>>>>> Although anything that makes me carry around fewer patches is good
>>>>> in my book.
>>>>>
>>>>> Dave
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe
>>> linux-security-module" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>> -- 
>> This message was distributed to subscribers of the selinux mailing list.
>> If you no longer wish to subscribe, send mail to
>> majordomo@tycho.nsa.gov with
>> the words "unsubscribe selinux" without quotes as the message.
>
>

