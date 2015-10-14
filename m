Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:57920 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932108AbbJNRhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 13:37:19 -0400
Subject: Re: [PATCH v5 5/9] vfs: Copy shouldn't forbid ranges inside the same
 file
To: Christoph Hellwig <hch@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-6-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142233.GC31867@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561E92C9.7040205@Netapp.com>
Date: Wed, 14 Oct 2015 13:37:13 -0400
MIME-Version: 1.0
In-Reply-To: <20151011142233.GC31867@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I would have folded this and patch 4 earlier if I had written patch 1, but I didn't feel comfortable modifying Zach's work too much.  I can make that change if it's not really a problem.

Anna

On 10/11/2015 10:22 AM, Christoph Hellwig wrote:
> Needs to be folded.
> 

