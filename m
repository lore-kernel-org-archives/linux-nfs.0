Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:46581 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab1HQJR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 05:17:28 -0400
Message-ID: <4E4B8724.4050101@itwm.fraunhofer.de>
Date: Wed, 17 Aug 2011 11:17:24 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: Andreas Dilger <adilger@whamcloud.com>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org, hch@infradead.org,
        yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org, tytso@mit.edu
Subject: Re: [PATCH 2/6] Return 32/64-bit dir name hash according to usage
 type
References: <20110816112536.1808464.7174.stgit@fsdevel3> <20110816112547.1808464.77625.stgit@fsdevel3> <123AAA92-9EEF-4FB7-AA7B-B179BC0626BA@whamcloud.com>
In-Reply-To: <123AAA92-9EEF-4FB7-AA7B-B179BC0626BA@whamcloud.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/16/2011 11:22 PM, Andreas Dilger wrote:
>> +static inline int is_32bit_api(void) +{ +#ifdef
>> HAVE_IS_COMPAT_TASK +	return is_compat_task();
>
> Looking more closely, this should actually be "#ifdef CONFIG_COMPAT"
> in the mainline kernel.
>
> HAVE_IS_COMPAT_TASK is from the Lustre configure script for detecting
> which kernel is_compat_task() was added in, since it appeared in some
> kernels at 2.6.17 but wasn't in most arches until 2.6.29.
>
> Sorry I didn't notice this earlier.
>

Oh no, I also should have noticed it :( I even made a small test program 
[1], but I then never executed it in 32bit mode :(


Cheers,
Bernd

[1]
http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
