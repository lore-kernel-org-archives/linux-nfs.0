From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 09/12] NFSv4.1: remove GETATTR from ds commits
Date: Wed, 23 Mar 2011 16:32:50 -0400
Message-ID: <AANLkTi=_+22+7-bw_Y7q4NpF16B7G3wNin7r7EkJNg7n@mail.gmail.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
	<1300886875-5016-10-git-send-email-iisaman@netapp.com>
	<4D8A4F2B.5040007@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39900 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145Ab1CWUcv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 16:32:51 -0400
Received: by bwz15 with SMTP id 15so6995829bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 13:32:50 -0700 (PDT)
In-Reply-To: <4D8A4F2B.5040007@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/3/23 Benny Halevy <bhalevy@panasas.com>:
> On 2011-03-23 15:27, Fred Isaman wrote:
>> Any COMMIT compound directed to a data server needs to have the
>> GETATTR calls suppressed. =A0We here, make sure the field we are tes=
ting
>
> s/We/While/?
>

Yes.

=46red
