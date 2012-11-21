Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:33671 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752489Ab2KUAEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2012 19:04:09 -0500
Message-ID: <50AC1A74.7080105@davequigley.com>
Date: Tue, 20 Nov 2012 19:04:04 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Casey Schaufler <casey@schaufler-ca.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50ABF1A5.2010406@schaufler-ca.com>
In-Reply-To: <50ABF1A5.2010406@schaufler-ca.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/20/2012 4:09 PM, Casey Schaufler wrote:
> On 11/11/2012 10:15 PM, David Quigley wrote:
>> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
>> specification and it has been decided that a reposting of the Labeled NFS code
>> for inclusion into mainline was a good idea. The patches have been rebased onto
>> v3.7-rc2 and have been tested against the SELinux testsuite with the only
>> failures being for features not supported by NFS.
>
> I'm trying to get the user space tools built so that I can
> do Smack testing. The instructions on selinuxproject.org
> seen out of date with regard to the packages required to
> build the NFS tools. I have failed to build on Fedora 17
> and Ubuntu 12.04. Any pointers beyond what's on the wiki?
>
> Thank you.
>
>
>   --
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.
>
>

There are a bunch of libs that need to be installed for it to compile 
properly. Unfortunately there are new dependencies which have been added 
since I updated the wiki last. I unfortunately don't remember what they 
are. What I did to build it last time though was to apply the one patch 
onto the latest tag from the nfs-utils tree. Unfortunately I don't have 
a clean vm on hand at the moment so I can't manually go through and list 
all the packages for you. A heavy handed approach that should still work 
is that I can give you my rpm list from my VM and then you can just make 
sure you have all the devel packages installed. Another option would be 
to grab the nfs-utils srpm for fedora 17 and just add the patch into the 
spec file. That would work too and tell you the build dependencies you 
need. I could also just try to make that for you and put the RPM up but 
that wouldn't be for a few days at the earliest.

Dave
