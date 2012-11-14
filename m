Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:50446 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752342Ab2KNOBh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 09:01:37 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 14 Nov 2012 09:01:36 -0500
From: David Quigley <dpquigl@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>,
        "David P. Quigley" <selinux@davequigley.com>,
        <trond.myklebust@netapp.com>, <sds@tycho.nsa.gov>,
        <linux-nfs@vger.kernel.org>, <selinux@tycho.nsa.gov>,
        <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <20121114135939.GE23604@fieldses.org>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <20121112152335.GH30713@fieldses.org> <50A116F0.5050404@davequigley.com>
 <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com>
 <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com>
 <50A31EF5.1050801@davequigley.com> <20121114134535.GD23604@fieldses.org>
 <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net>
 <20121114135939.GE23604@fieldses.org>
Message-ID: <6fc201d796587ac166a8b45467b087cc@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/14/2012 08:59, J. Bruce Fields wrote:
> On Wed, Nov 14, 2012 at 08:50:17AM -0500, David Quigley wrote:
>> On 11/14/2012 08:45, J. Bruce Fields wrote:
>> >On Tue, Nov 13, 2012 at 11:32:53PM -0500, Dave Quigley wrote:
>> >>Ok so if you go to http://www.selinuxproject.org/git you will see 
>> a
>> >>repo for lnfs and lnfs-patchset. The instructions at
>> >>http://www.selinuxproject.org/page/Labeled_NFS give you a better
>> >>indication on how to pull the trees. I've attached a patch for NFS
>> >>utils which gives support for security_label/nosecurity_label in
>> >>your /etc/exports file.
>> >
>> >Do we need an export option?  Is there any reason not to make the
>> >feature available whenever there's support available for it?
>>
>> I guess we could build it in but I figured an export option allowed
>> someone to turn off security labeling support if they didn't want it
>> on that export. What happens to clients when the server returns a
>> cap that they don't support? Do they mask the bits out?
>
> Yeah, they should just ignore it.
>
> While this is still experimental it's still nice to have a way to 
> turn
> this on and off at runtime so people can experiment without having to
> have it on for everyone all the time.  But 
> nfsd_supported_minorversion
> should be sufficient for that.
>
> (I don't think your patches actually dealt yet with the fact that 
> this
> is part of minor version 2?  Another for the todo list.)
>
> --b.

Hmm... I'll have to look at the patches again to find out. Its been so 
long since I worked on these full time that I have to go back and check 
quite a bit. Luckily since i put the tree up for Trond last night I 
should be able to look at them while at work.
