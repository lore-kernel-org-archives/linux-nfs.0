Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58826 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab3BLVle (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 16:41:34 -0500
Date: Tue, 12 Feb 2013 16:41:31 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
Message-ID: <20130212214131.GI10267@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2013 at 07:39:08AM -0500, Steve Dickson wrote:
>  include/linux/security.h            |  57 +++-
...
>  security/capability.c               |  19 +-
>  security/security.c                 |  24 +-
>  security/selinux/hooks.c            |  92 +++++-
>  security/selinux/include/security.h |   2 +
>  security/selinux/ss/policydb.c      |   5 +-
>  security/smack/smack_lsm.c          |  11 +
>  33 files changed, 1352 insertions(+), 214 deletions(-)

Are we still waiting on ACKs from the security people for these bits?

--b.
