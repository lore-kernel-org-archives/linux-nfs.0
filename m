Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:40134 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbbBEK6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 05:58:03 -0500
Received: by mail-wg0-f42.google.com with SMTP id x13so6914138wgg.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 02:58:02 -0800 (PST)
Message-ID: <54D34CB8.1040008@plexistor.com>
Date: Thu, 05 Feb 2015 12:58:00 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: dE <de.techno@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
References: <54D237A5.1050302@gmail.com> <20150204170356.14e1e381@harpe.intellique.com> <54D24403.2080403@gmail.com>
In-Reply-To: <54D24403.2080403@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/04/2015 06:08 PM, dE wrote:
> On 02/04/15 21:33, Emmanuel Florac wrote:
>> Le Wed, 04 Feb 2015 20:45:49 +0530
>> dE <de.techno@gmail.com> écrivait:
>>
>>> I'm trying to export a particular directory with these parameters --
>>>
>>> /home/test/huge/temp_small/subdir
>>> fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)
>>>
>>> For all subdirectories in temp_small, the client fails to mount
>>> saying permission denied.
>> Is temp_small a mountpoint? What are the mount options?
>>
> 
> No, the previous directory is (huge)
> 
> /dev/sda15 on /home/test/huge type reiser4 (rw,noatime)

Sorry if this is a stupid question, but what is "reiser4" filesystem ?

Looking at the Kernel source I have, I see registered "reiserfs" filesystem.

Reason I'm asking is because it looks a little bit like when the FS does not
support the export_operations vector. The Kernel nfsd is not very good
in complaining about it properly

Boaz

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

