Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:63155 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaDRQZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 12:25:54 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so1584836pde.15
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 09:25:53 -0700 (PDT)
Message-ID: <535151F1.1070102@gmail.com>
Date: Sat, 19 Apr 2014 00:25:21 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Checking whether kill_suid by should_remove_suid()
References: <534AA92B.8010805@gmail.com> <20140418130220.GF18612@fieldses.org>
In-Reply-To: <20140418130220.GF18612@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2014/4/18 21:02, J. Bruce Fields wrote:
> On Sun, Apr 13, 2014 at 11:11:39PM +0800, Kinglong Mee wrote:
>> As local filesystem, writing data to the file by non-owner will
>> clears the SUID+SGID, owner will not.
>
> Are you sure about this?  (Do you have a test case that fails?)
>
> I don't see an owner check in should_remove_suid.
>
> And I think that an nfsd thread will always have CAP_FSETID set (see
> cap_raise_nfsd_set and the definition of CAP_NFSD_SET), so that
> should_remove_suid() will always return 0.

You are right, should_remove_suid always return 0, nfsd will never call
kill_suid(). Coincidentally, that's the fix for bug of root clears the
SUID/SGID after writing data.

The right fix should drops the kill_suid(), because vfs_writev() have
do it correctly. I have push a new patch.

thanks,
Kinglong Mee
