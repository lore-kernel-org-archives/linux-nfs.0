Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35418 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751497AbcLWJS0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2016 04:18:26 -0500
Received: by mail-pg0-f66.google.com with SMTP id i5so13537930pgh.2
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2016 01:18:25 -0800 (PST)
Subject: Re: [PATCH 1/3] NFSD: pass an integer for stable type to
 nfsd_vfs_write
To: Christoph Hellwig <hch@infradead.org>
References: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
 <20161223071928.GA19287@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <ff5a91f2-000b-eaf8-d224-fb113d54f1e1@gmail.com>
Date: Fri, 23 Dec 2016 17:18:03 +0800
MIME-Version: 1.0
In-Reply-To: <20161223071928.GA19287@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/23/2016 15:19, Christoph Hellwig wrote:
> On Fri, Dec 23, 2016 at 09:32:15AM +0800, Kinglong Mee wrote:
>> Commit fae5096ad217 "nfsd: assume writeable exportabled filesystems have f_sync"
>> have remove the setting of stable.
> 
> Btw, that commit really should check for fsync support at export
> time then, never underestimate how broken file systems could be.
> 

We can check it in check_export() when exporting filesystem,
but, what can we do for the unsupported fsync filesystem?
Just a warning message? or deny the exporting? 
I'd prefer the first one.

thanks,
Kinglong Mee
