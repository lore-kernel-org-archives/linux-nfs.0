Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:54309 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbaGLRPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Jul 2014 13:15:02 -0400
Message-ID: <53C16D12.90109@gmx.de>
Date: Sat, 12 Jul 2014 19:14:58 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de> <53C12A93.3040803@gmail.com>
In-Reply-To: <53C12A93.3040803@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2014 02:31 PM, Kinglong Mee wrote:
> I think it is caused by kfree an uninitialized address.
> Can you test with the patch listed in following url,
> I have send some days before ?
> 
> "[PATCH 1/4] NFSD: Fix memory leak in encoding denied lock"
> http://www.spinics.net/lists/linux-nfs/msg44719.html
> 
> thanks,
> Kinglong Mee
> 
That patch seems to fix the issue.



-- 
Toralf

