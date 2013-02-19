Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933529Ab3BSUUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 15:20:20 -0500
Message-ID: <5123DE7F.7050803@RedHat.com>
Date: Tue, 19 Feb 2013 15:20:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/14] lnfs: 3.8-rc7 release
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com> <20130218195834.GA3391@fieldses.org> <512395D7.5010205@RedHat.com> <20130219151808.GE3391@fieldses.org> <51239CFF.9000600@RedHat.com>
In-Reply-To: <51239CFF.9000600@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19/02/13 10:40, Steve Dickson wrote:
>>>> >>> Also: did you figure out why NFSv4 wasn't working when the labeled NFS
>>>> >>> support is configured out?
>>> >> I'll look into this but this was not the case the last time I checked...
>> > 
>> > Let me know how I can help reproduce the problem.  All I did was:
>> > 
>> > 	- build a kernel with CONFIG_NFS_V4_SECURITY_LABEL and
>> > 	  CONFIG_NFSD_V4_SECURITY_LABEL both off.
>> > 	- attempt a v4 mount between client and server both running that
>> > 	  kernel.
The bug is due to the fact the the bit masked used when labels are not
wanted (attr_bitmask_nl) was not being initialized when CONFIG_NFS_V4_SECURITY_LABEL
is not defined. Nice catch!

steved.
