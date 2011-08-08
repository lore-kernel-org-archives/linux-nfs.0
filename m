Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43372 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab1HHPBs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 11:01:48 -0400
Received: by vws1 with SMTP id 1so3455177vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2011 08:01:47 -0700 (PDT)
Message-ID: <1593054604-1312815702-cardhu_decombobulator_blackberry.rim.net-1846586384-@b27.c3.bise3.blackberry>
Reply-To: bhalevy@tonian.com
Subject: Re: [PATCH-RFC 0/2] pNFS: recoalesce pages when ld read/write fails
To: "Peng Tao" <bergwolf@gmail.com>, linux-nfs@vger.kernel.org
Cc: rees@umich.edu, Trond.Myklebust@netapp.com
From: "Benny Halevy" <bhalevy@tonian.com>
Date: Mon, 8 Aug 2011 15:01:39 +0000
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm good with a private pnfs workqueue.

Benny
------Original Message------
From: Peng Tao
To: linux-nfs@vger.kernel.org
Cc: rees@umich.edu
Cc: Benny Halevy
Cc: Trond.Myklebust@netapp.com
Subject: Re: [PATCH-RFC 0/2] pNFS: recoalesce pages when ld read/write fails
Sent: Aug 8, 2011 17:33

On Sat, Aug 6, 2011 at 11:52 PM, Peng Tao <bergwolf@gmail.com> wrote:
> Hi,
>
> I start to look at the error handling for ld_read/write_done.
> The two patches try to address the error handling for read/write pagelist
> failures, via nfs readpage/writepage interface. Please see if this method
> is proper. Thanks!
FWIW, this is just what we need for recoalescing pages when IO fails.
Currently ld_read/write_done is called in default workqueue, which is
not really a good place for IO path code. Trond mentioned that nfsiod
is not an ideal place for it either. So do we need to create a pnfs
private workqueue for this? Any other suggestions?

-- 
Thanks,
-Bergwolf


