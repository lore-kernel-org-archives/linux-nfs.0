Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52218 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab3BMALp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 19:11:45 -0500
Date: Tue, 12 Feb 2013 19:11:41 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
Message-ID: <20130213001141.GA14195@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get failures on NFSv4 mounts after applying these patches.

	# mount -tnfs4  pip1:/exports/ext4 /mnt/
	mount.nfs4: mounting pip1:/exports/ext4 failed, reason given by server: No such file or directory

In wireshark I don't see an error, but I do notice that the final
rpc request and reply is a getattr with bitmap 0, which is odd.

--b.
