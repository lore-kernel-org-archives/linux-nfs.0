Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:50760 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1161179Ab2KNOaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 09:30:04 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 14 Nov 2012 09:30:02 -0500
From: David Quigley <dpquigl@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>,
        "David P. Quigley" <selinux@davequigley.com>,
        <trond.myklebust@netapp.com>, <sds@tycho.nsa.gov>,
        <linux-nfs@vger.kernel.org>, <selinux@tycho.nsa.gov>,
        <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <20121114142458.GF23604@fieldses.org>
References: <50A116F0.5050404@davequigley.com>
 <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com>
 <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com>
 <50A31EF5.1050801@davequigley.com> <20121114134535.GD23604@fieldses.org>
 <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net>
 <20121114135939.GE23604@fieldses.org>
 <80f36fef2a58eb538bce28daba3a862a@countercultured.net>
 <20121114142458.GF23604@fieldses.org>
Message-ID: <4f9b24e3942b4a28cd9068d5bc0135fa@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/14/2012 09:24, J. Bruce Fields wrote:
> On Wed, Nov 14, 2012 at 09:04:18AM -0500, David Quigley wrote:
>> On 11/14/2012 08:59, J. Bruce Fields wrote:
>> >On Wed, Nov 14, 2012 at 08:50:17AM -0500, David Quigley wrote:
>> >>On 11/14/2012 08:45, J. Bruce Fields wrote:
>> >>>On Tue, Nov 13, 2012 at 11:32:53PM -0500, Dave Quigley wrote:
>> >>>>Ok so if you go to http://www.selinuxproject.org/git you will
>> >>see a
>> >>>>repo for lnfs and lnfs-patchset. The instructions at
>> >>>>http://www.selinuxproject.org/page/Labeled_NFS give you a better
>> >>>>indication on how to pull the trees. I've attached a patch for 
>> NFS
>> >>>>utils which gives support for security_label/nosecurity_label in
>> >>>>your /etc/exports file.
>> >>>
>> >>>Do we need an export option?  Is there any reason not to make the
>> >>>feature available whenever there's support available for it?
>> >>
>> >>I guess we could build it in but I figured an export option 
>> allowed
>> >>someone to turn off security labeling support if they didn't want 
>> it
>> >>on that export. What happens to clients when the server returns a
>> >>cap that they don't support? Do they mask the bits out?
>> >
>> >Yeah, they should just ignore it.
>> >
>> >While this is still experimental it's still nice to have a way to
>> >turn
>> >this on and off at runtime so people can experiment without having 
>> to
>> >have it on for everyone all the time.  But
>> >nfsd_supported_minorversion
>> >should be sufficient for that.
>> >
>> >(I don't think your patches actually dealt yet with the fact that
>> >this
>> >is part of minor version 2?  Another for the todo list.)
>> >
>> >--b.
>>
>> If we use nfsd_supported_minorversion which I'm guessing is an
>> export option
>
> That's just a variable in the code.  It's controlled by
> /proc/fs/nfsd/versions.
>
>> what happens if someone wants to use other 4.2
>> features but not labeling?
>
> We'll cross that bridge when we come to it, maybe by adding some new
> global paramater.
>
> There's no reason this really needs to be per-export, is there?
>
> --b.

At the moment I can't really think of a reason to have it be 
per-export. I think we need a new LSM patch though to determine if the 
LSM supports labeling over NFS unless Steve can think of a better way to 
tell if the LSM supports labeling.


>
>> I'll switch it over if you guys want it
>> done that way, I think though that this provides more flexibility.
>> Although anything that makes me carry around fewer patches is good
>> in my book.
>>
>> Dave

