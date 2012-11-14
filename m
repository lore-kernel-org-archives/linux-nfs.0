Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:50366 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752342Ab2KNN4n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 08:56:43 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 14 Nov 2012 08:56:42 -0500
From: David Quigley <selinux@davequigley.com>
To: Dave Quigley <dpquigl@davequigley.com>
Cc: Steve Dickson <steved@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, <trond.myklebust@netapp.com>,
        <sds@tycho.nsa.gov>, <linux-nfs@vger.kernel.org>,
        <selinux@tycho.nsa.gov>, <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <50A31EF5.1050801@davequigley.com>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <20121112152335.GH30713@fieldses.org> <50A116F0.5050404@davequigley.com>
 <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com>
 <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com>
 <50A31EF5.1050801@davequigley.com>
Message-ID: <89250d50cb98ad1e39a9e8259312510c@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/13/2012 23:32, Dave Quigley wrote:
> On 11/13/2012 7:55 AM, Steve Dickson wrote:
>>
>>
>> On 12/11/12 20:39, Dave Quigley wrote:
>>> If you're ok with non Fedora kernel images I can try to put up a 
>>> tree either tonight or tomorrow with the patches that you just need 
>>> to build and install. That plus the one patch for nfs-utils should 
>>> make everything work.
>> I'm good with that....
>>
>> steved.
>>
>
> Ok so if you go to http://www.selinuxproject.org/git you will see a
> repo for lnfs and lnfs-patchset. The instructions at
> http://www.selinuxproject.org/page/Labeled_NFS give you a better
> indication on how to pull the trees. I've attached a patch for NFS
> utils which gives support for security_label/nosecurity_label in your
> /etc/exports file. I've also attached a script called setup which
> should build a test directory called /export with a copy of /var/www
> under it which should be labeled properly. It does all the proper
> SELinux commands to make sure labeling is correct. Once you have that
> setup just mount -t nfs localhost:/ /mnt/lnfs (or wherever you want)
> and you should be good to go. Just ls -Z in /mnt/lnfs/var and check 
> to
> make sure the labels are the same as /export/var. It should have the
> labels showing up in the network transfer. If you have any problems
> just let me know and I can try to help figure them out.
>
> Dave

If you want to run the testsuite we used Serge has a repo on the git 
page above for the selinux-testsuite. Just copy it onto the nfs export 
and follow the instructions in the readme.
