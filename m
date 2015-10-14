Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:37403 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbbJNS2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:28:11 -0400
Subject: Re: [PATCH v5 5/9] vfs: Copy shouldn't forbid ranges inside the same
 file
To: Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-6-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142233.GC31867@infradead.org> <561E92C9.7040205@Netapp.com>
 <20151014182523.GA31225@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561E9EAA.5000808@Netapp.com>
Date: Wed, 14 Oct 2015 14:27:54 -0400
MIME-Version: 1.0
In-Reply-To: <20151014182523.GA31225@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/14/2015 02:25 PM, Christoph Hellwig wrote:
> On Wed, Oct 14, 2015 at 01:37:13PM -0400, Anna Schumaker wrote:
>> I would have folded this and patch 4 earlier if I had written patch 1,
>> but I didn't feel comfortable modifying Zach's work too much.  I can
>> make that change if it's not really a problem.
> 
> Folding the changes is perfectly fine, just make it clear you changed
> it, e.g.
> 
> Signed-off-by: Original Author <original@auhor.info>
> [anna: fixed foo & bar, rewrote changelog]
> Signed-off-by: Anna Schumaker <Anna.Schumaker@netapp.com>
> 

Okay, I'll do that.  Thanks!

Anna
