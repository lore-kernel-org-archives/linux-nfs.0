Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40536 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbcGXAWo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jul 2016 20:22:44 -0400
Date: Sun, 24 Jul 2016 01:22:06 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Oleg Drokin <green@linuxhacker.ru>, Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/7] nfsd: remove redundant i_lookup check
Message-ID: <20160724002152.GN2356@ZenIV.linux.org.uk>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
 <1469209736-6490-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1469209736-6490-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 22, 2016 at 01:48:52PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> I'm not sure why this was added.  It doesn't seem necessary, and no
> other caller does this.

lookup_one_len() will explode if you call it for non-directory (==
!d_can_lookup(), i.e. something without ->lookup()).  So unless the callers
do guarantee that check being true, it *is* needed.
