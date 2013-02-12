Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753642Ab3BLXLU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 18:11:20 -0500
Date: Tue, 12 Feb 2013 18:11:13 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
Message-ID: <20130212231113.GQ10267@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So originally I thought Dave was saying we'd try to get the label change
attribute in the initial submission.  I guess it'll be coming later
instead?

This is going to be a part of NFSv4.2, so shouldn't this really come
with patches to implement minor version 2?  (Should be totally trivial
as it doesn't have to do anything other than labeled NFS for now.)

If not, that's another reason why we don't want to recommend building
this by default.  Though maybe advertising labeled NFS support in v4.1
won't cause a problem for any implementation in practice, I don't know.

--b.
