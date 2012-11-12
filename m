Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36209 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613Ab2KLQdR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 11:33:17 -0500
Date: Mon, 12 Nov 2012 11:33:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Quigley <dpquigl@davequigley.com>
Cc: trond.myklebust@netapp.com, sds@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
Message-ID: <20121112163314.GM30713@fieldses.org>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 12, 2012 at 01:15:34AM -0500, David Quigley wrote:
> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
> specification and it has been decided that a reposting of the Labeled NFS code
> for inclusion into mainline was a good idea. The patches have been rebased onto
> v3.7-rc2 and have been tested against the SELinux testsuite with the only
> failures being for features not supported by NFS.

This will still need support for FATTR4_CHANGE_SEC_LABEL.

--b.
