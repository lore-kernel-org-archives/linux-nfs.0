Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35423 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752580AbcLaJRN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Dec 2016 04:17:13 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so22808553pfk.2
        for <linux-nfs@vger.kernel.org>; Sat, 31 Dec 2016 01:17:13 -0800 (PST)
Subject: Re: [PATCH 1/3] NFSD: pass an integer for stable type to
 nfsd_vfs_write
To: Christoph Hellwig <hch@infradead.org>
References: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
 <20161223071928.GA19287@infradead.org>
 <ff5a91f2-000b-eaf8-d224-fb113d54f1e1@gmail.com>
 <20161223092554.GA17715@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <b7d23232-393c-325f-2fe0-a9dd5bda9cfc@gmail.com>
Date: Sat, 31 Dec 2016 17:16:43 +0800
MIME-Version: 1.0
In-Reply-To: <20161223092554.GA17715@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/23/2016 17:25, Christoph Hellwig wrote:
> On Fri, Dec 23, 2016 at 05:18:03PM +0800, Kinglong Mee wrote:
>> We can check it in check_export() when exporting filesystem,
>> but, what can we do for the unsupported fsync filesystem?
>> Just a warning message? or deny the exporting? 
>> I'd prefer the first one.
> 
> Warn and refuse the writable export.
> 

I'd like warn and covert the export to read-only straightly.

For example, 
A test directory may be mounted many underlay filesystem (contain
 ISO9660, f2fs, etc) frequently. If refuse the writeable export, 
for ISO9660 the exports entry must be *(ro,...), but for f2fs
may be *(rw,...). I don't think someone wants change it every time.

thanks,
Kinglong Mee
