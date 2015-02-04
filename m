Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f169.google.com ([74.125.82.169]:55116 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526AbbBDQIv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 11:08:51 -0500
Received: by mail-we0-f169.google.com with SMTP id u56so2693043wes.0
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 08:08:50 -0800 (PST)
Received: from [192.168.1.2] ([59.89.23.52])
        by mx.google.com with ESMTPSA id n3sm3326389wja.36.2015.02.04.08.08.49
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 08:08:50 -0800 (PST)
Message-ID: <54D24403.2080403@gmail.com>
Date: Wed, 04 Feb 2015 21:38:35 +0530
From: dE <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
References: <54D237A5.1050302@gmail.com> <20150204170356.14e1e381@harpe.intellique.com>
In-Reply-To: <20150204170356.14e1e381@harpe.intellique.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/04/15 21:33, Emmanuel Florac wrote:
> Le Wed, 04 Feb 2015 20:45:49 +0530
> dE <de.techno@gmail.com> écrivait:
>
>> I'm trying to export a particular directory with these parameters --
>>
>> /home/test/huge/temp_small/subdir
>> fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)
>>
>> For all subdirectories in temp_small, the client fails to mount
>> saying permission denied.
> Is temp_small a mountpoint? What are the mount options?
>

No, the previous directory is (huge)

/dev/sda15 on /home/test/huge type reiser4 (rw,noatime)
