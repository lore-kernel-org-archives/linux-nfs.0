Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35012 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbKJA4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2015 19:56:53 -0500
Date: Tue, 10 Nov 2015 00:56:45 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, clm@fb.com, darrick.wong@oracle.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v8 4/4] vfs: Add vfs_copy_file_range() support for
 pagecache copies
Message-ID: <20151110005645.GX22011@ZenIV.linux.org.uk>
References: <1446844701-848-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1446844701-848-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1446844701-848-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 06, 2015 at 04:18:20PM -0500, Anna Schumaker wrote:

> I moved the rw_verify_area() calls into the fallback code since some
> filesystems can handle reflinking a large range.


Take a look at rw_verify_area() - it does a lot more than "trim down to
2Gb" - starting with "deal with mandatory locks".  LSM checks as well...

So that one is bogus, IMO.  I've no problem with fallback per se, but
rw_verify_area() should be unconditional here.  If anything, we might
add a variant that would skip the "trim down to 2Gb" and use it there,
but skipping it entirely is wrong.
