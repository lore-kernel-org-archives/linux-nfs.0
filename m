Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab3BPUgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 15:36:22 -0500
Message-ID: <511FEDB7.9000505@RedHat.com>
Date: Sat, 16 Feb 2013 15:36:07 -0500
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
Subject: Re: [PATCH 12/15] lnfs: Do not sleep holding the inode spin lock
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <1360327163-20360-13-git-send-email-SteveD@redhat.com> <20130213151610.GI14195@fieldses.org>
In-Reply-To: <20130213151610.GI14195@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/02/13 10:16, J. Bruce Fields wrote:
> On Fri, Feb 08, 2013 at 07:39:20AM -0500, Steve Dickson wrote:
>> > From: Dave Quigley <dpquigl@taiga.selinuxproject.org>
>> > 
>> > The nfs_setsecurity code can sleep while allocating memory
>> > so the inode spin lock can not be held while during this call.
> If this is the right fix, it needs to be folded into patch 10/15, where
> the problem was introduced.
Gone! 

steved.
