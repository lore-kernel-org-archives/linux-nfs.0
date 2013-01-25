Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:50392 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596Ab3AYNp4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 08:45:56 -0500
Date: Fri, 25 Jan 2013 13:45:41 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: Ian Campbell <Ian.Campbell@citrix.com>
cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <0CC0BE5DF792540B7B6F1A5A@nimrod.local>
In-Reply-To: <1358781685.3279.222.camel@zakaz.uk.xensource.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>	
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>	
 <4B8CA29C9B365854E56ACBE6@Ximines.local>
 <1358781685.3279.222.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



--On 21 January 2013 15:21:25 +0000 Ian Campbell <Ian.Campbell@citrix.com> 
wrote:

>> >> I thought that Ian was working on a fix for this issue. At one point,
>> >> he had a bunch of patches to allow sendpage() to call you back when
>> >> the transmission was done. What happened to those patches?
>> >
>> > No idea (I don't work with Ian but have taken the liberty of copy him).
>
> I'm afraid I've rather dropped the ball on these patches due to lack of
> time.

I have a rebase of your patch set for 3.2 (done by Mel Gorman) which
whilst not onto the current version is better than nothing, so I shall
send it along to netdev in case it is useful.

-- 
Alex Bligh
