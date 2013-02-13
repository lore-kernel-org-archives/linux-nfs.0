Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52709 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460Ab3BMAVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 19:21:23 -0500
Date: Tue, 12 Feb 2013 19:21:18 -0500
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
Message-ID: <20130213002117.GB14195@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <20130213001141.GA14195@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213001141.GA14195@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2013 at 07:11:41PM -0500, J. Bruce Fields wrote:
> I get failures on NFSv4 mounts after applying these patches.
> 
> 	# mount -tnfs4  pip1:/exports/ext4 /mnt/
> 	mount.nfs4: mounting pip1:/exports/ext4 failed, reason given by server: No such file or directory
> 
> In wireshark I don't see an error, but I do notice that the final
> rpc request and reply is a getattr with bitmap 0, which is odd.

Oh, and that was a build with labeled nfs configured out.

--b.
