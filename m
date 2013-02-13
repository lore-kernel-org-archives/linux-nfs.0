Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35426 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679Ab3BMPFT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 10:05:19 -0500
Date: Wed, 13 Feb 2013 10:05:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
Message-ID: <20130213150509.GH14195@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <20130213001141.GA14195@fieldses.org>
 <20130213002117.GB14195@fieldses.org>
 <511ADE41.2040904@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511ADE41.2040904@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2013 at 07:28:49PM -0500, Steve Dickson wrote:
> 
> 
> On 12/02/13 19:21, J. Bruce Fields wrote:
> > On Tue, Feb 12, 2013 at 07:11:41PM -0500, J. Bruce Fields wrote:
> >> I get failures on NFSv4 mounts after applying these patches.
> >>
> >> 	# mount -tnfs4  pip1:/exports/ext4 /mnt/
> >> 	mount.nfs4: mounting pip1:/exports/ext4 failed, reason given by server: No such file or directory
> >>
> >> In wireshark I don't see an error, but I do notice that the final
> >> rpc request and reply is a getattr with bitmap 0, which is odd.
> > 
> > Oh, and that was a build with labeled nfs configured out.
> Drop the -tnfs4 option...

Well, sure, then it'll negotiate down to v3 and the mount will succeed.

But if you request v4 (either with -tnfs4 or -onfsvers=4), it fails.

In other words, these patches break NFSv4 mounts in the default
(CONFIG_NFS_V4_SECURITY_LABEL=n) case.

--b.

> I think it has something to do with breaking up the version into 
> modules... I never investigated why that worked...  
> 
> steved.
> 
