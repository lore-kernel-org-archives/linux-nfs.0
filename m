Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from honeysuckle.london.02.net ([87.194.255.144]:59616 "EHLO
	honeysuckle.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966056Ab0GPQQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 12:16:57 -0400
Received: from [192.168.1.65] (87.194.12.203) by honeysuckle.london.02.net (8.5.124.03)
        id 4C1F9BC200F74443 for linux-nfs@vger.kernel.org; Fri, 16 Jul 2010 17:10:31 +0100
Message-ID: <4C408470.1090709@limepepper.co.uk>
Date: Fri, 16 Jul 2010 17:10:24 +0100
From: Tom H <tom@limepepper.co.uk>
CC: linux-nfs@vger.kernel.org
Subject: Re: why do attempts to access a nfs v3 filesystem (ro,soft) block
 the process for minutes at a time? (when the nfs server is down)
References: <4C4078AE.5070300@limepepper.co.uk> <4C4079CC.8070205@oracle.com>
In-Reply-To: <4C4079CC.8070205@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> On 07/16/2010 11:20 AM, Tom H wrote:
>>
>> (also I noticed that it seems to timeout quicker with the mount options
>> set like (soft, timeo=7, retrans=3) which is unexpected, because they
>> are supposed to be the default)
>
> They are the default settings for UDP mounts, but you didn't specify 
> UDP.  TCP is the default transport protocol, and has been for some 
> time.  TCP uses a long retransmit timeout.  See nfs(5).
>
OK, I see that now. Thanks.!

However further experimentation with mount options 
(ro,soft,retrans=0,timeo=0,intr,proto=tcp) - requests to a failed nfs 
file-system still block the apache process for some apparently random 
time up to 3 minutes.

Cheers
T
