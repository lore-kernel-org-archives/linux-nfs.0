Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932551Ab3BSPKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 10:10:21 -0500
Message-ID: <512395D7.5010205@RedHat.com>
Date: Tue, 19 Feb 2013 10:10:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/14] lnfs: 3.8-rc7 release
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com> <20130218195834.GA3391@fieldses.org>
In-Reply-To: <20130218195834.GA3391@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 18/02/13 14:58, J. Bruce Fields wrote:
> On Mon, Feb 18, 2013 at 01:47:42PM -0500, Steve Dickson wrote:
>> > From: Steve Dickson <steved@redhat.com>
>> > 
>> > Here is the next release of the Label NFS patches, forward 
>> > ported to linux-3.8-rc7
>> > 
>> > I believe I've  incorporated all code review that were made
>> > from the last release,
> Except I think this doesn't turn on minor version 2?
Are you saying we need a -o v4.2 mount option to enable this feature?

> 
> Also: did you figure out why NFSv4 wasn't working when the labeled NFS
> support is configured out?
I'll look into this but this was not the case the last time I checked...

steved.

