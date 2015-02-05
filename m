Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41297 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbbBECev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 21:34:51 -0500
Received: by pdiy13 with SMTP id y13so4647926pdi.8
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 18:34:51 -0800 (PST)
Received: from [192.168.1.2] ([59.89.23.52])
        by mx.google.com with ESMTPSA id u5sm3338042pdh.54.2015.02.04.18.34.42
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 18:34:50 -0800 (PST)
Message-ID: <54D2D6B0.4010402@gmail.com>
Date: Thu, 05 Feb 2015 08:04:24 +0530
From: dE <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
References: <54D237A5.1050302@gmail.com>	<20150204170356.14e1e381@harpe.intellique.com>	<54D24403.2080403@gmail.com> <20150204173039.421c3192@harpe.intellique.com>
In-Reply-To: <20150204173039.421c3192@harpe.intellique.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/04/15 22:00, Emmanuel Florac wrote:
> Le Wed, 04 Feb 2015 21:38:35 +0530
> dE <de.techno@gmail.com> écrivait:
>
>> No, the previous directory is (huge)
>>
>> /dev/sda15 on /home/test/huge type reiser4 (rw,noatime)
> And does exporting from some other place in the same filesystem
> (/home/test/huge/whatever) work ?
>
> I suppose reiser4 is 64 bits. what's the inode number of
> /home/test/huge/temp_small/subdir ?
> I've seen problems on some systems mounting inodes with large (not 32
> bits compatible) numbers.
>
> Another problem I've seen was when mixing clients with 3.8 kernel and
> servers with 3.2 kernels.
>

No. For any directory it doesn't work.

There is a stranger behavior. If I mount the parent directory of the 
export like /home/test/huge/temp_small or /home/test/huge (when 
/home/test/huge/whatever is exported), it mounts and only the exported 
directory is accessible/seen. However all_squash flag does not appear to 
be working with /home/test/huge/temp_small; I cant access 
/home/test/huge/temp_small/subdir as root.

But it appears to be working for localhost.

The inodes are 32 bit. e.g. 297618, 264250, 280589 etc...

On one end I'm running the server on 3.17 and the client on 3.10.
