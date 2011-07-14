Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:50063 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab1GNR7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 13:59:11 -0400
Received: by fxd18 with SMTP id 18so1439958fxd.11
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 10:59:10 -0700 (PDT)
Message-ID: <4E1F2E66.5050903@tonian.com>
Date: Thu, 14 Jul 2011 20:59:02 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Janson <haozi_sdu@163.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: A problem about pnfs+ext4
References: <6b2497dd.90ba.1310f94bd6e.Coremail.haozi_sdu@163.com>
In-Reply-To: <6b2497dd.90ba.1310f94bd6e.Coremail.haozi_sdu@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Janson, I started looking at this.
This seems is a genuine issue with the current implementation.
It might take me a while to give you a patch to test
due to other burning stuff on my queue.
But anyhow, thanks for reporting this!

Benny

On 2011-07-09 18:47, Janson wrote:
> In the pnfs + ext4 test,we found a problem: when writting a file in pnfs 
> we can not read the contents from ext4. After studying we found that 
> ext4 extent have a  initialize flag, when pnfs call fallocate, the flag will 
> be set to 1, but after pnfs writting data by truncate, the flags can not 
> be set to 0. If the flag is 1,ext4 can not read the content.
> Now,in ext4 code,The only wan that ext4 set the flag to 0 is DIO. 
> Do you know how to solve this problem?
> 
> 
> Best regards,
> Janson
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
