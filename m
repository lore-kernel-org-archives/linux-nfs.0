Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36842 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbbGIJb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 05:31:29 -0400
Received: by pdjr16 with SMTP id r16so1168312pdj.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 02:31:29 -0700 (PDT)
Message-ID: <559E3F68.6090205@gmail.com>
Date: Thu, 09 Jul 2015 17:31:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 1/5] nfsd: Fix a file leak of ls_file if nfsd4_layout_setlease
 fail
References: <559672B7.4010802@gmail.com> <20150708213015.GG19084@fieldses.org> <20150709081239.GB19291@infradead.org>
In-Reply-To: <20150709081239.GB19291@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 16:12, Christoph Hellwig wrote:
> On Wed, Jul 08, 2015 at 05:30:15PM -0400, J. Bruce Fields wrote:
>> Hm, is the stateid really completely enough set up that this is safe?
> 
> It's not.  nfsd4_free_layout_stateid unconditionally deletes
> from the per-client and per-file lists which are empty at this
> point.  Just adding an explicit fput would be the better fix.
> 

Got it.

thanks,
Kinglong Mee
