Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59116 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbIEIdr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Sep 2015 04:33:47 -0400
Date: Sat, 5 Sep 2015 09:33:42 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
Message-ID: <20150905083342.GG22011@ZenIV.linux.org.uk>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <4B41043F-5D85-42D6-8F20-2DCC45930EF4@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B41043F-5D85-42D6-8F20-2DCC45930EF4@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:25:27PM -0600, Andreas Dilger wrote:

> This is a bit of a surprising result, since in my testing in the
> past, copy_{to/from}_user() is a major consumer of CPU time (50%
> of a CPU core at 1GB/s).  What backing filesystem did you test on?

While we are at it, was cp(1) using read(2)/write(2) loop or was it using
something else (sendfile(2), for example)?
