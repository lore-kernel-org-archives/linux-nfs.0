Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f177.google.com ([74.125.82.177]:52335 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3I2Lyr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 07:54:47 -0400
Received: by mail-we0-f177.google.com with SMTP id t60so4238648wes.8
        for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 04:54:45 -0700 (PDT)
Message-ID: <52481502.1010108@primarydata.com>
Date: Sun, 29 Sep 2013 14:54:42 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
References: <52447EA0.7070004@primarydata.com> <20130929114240.GA25750@infradead.org>
In-Reply-To: <20130929114240.GA25750@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 14:42, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:36:16PM -0400, Benny Halevy wrote:
>> The following patchset implements an extension to nfsd
>> providing a complete minimal pnfs server exporting
>> DLM-based clustered file systems such as GFS2 or OCFS2.
> 
> Does this actually buy us anything by now?  Last time I saw numbers for
> this implementation it was slower than an active/passive setup over
> those filesystem due to the way their cluster locking works.
> 

Was this for write sharing or read only?
As far as I understand, the share locks do not cause arbitration
and they do provide bandwidth scalability via multiple nodes.
That said, it is worth measuring.

Benny
