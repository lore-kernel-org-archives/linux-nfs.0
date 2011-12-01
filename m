Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40254 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab1LARZg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:25:36 -0500
Received: by ggnr5 with SMTP id r5so2022221ggn.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 09:25:35 -0800 (PST)
Message-ID: <4ED7B88C.2080405@gmail.com>
Date: Thu, 01 Dec 2011 11:25:32 -0600
From: Bruce Dubbs <bruce.dubbs@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs server issues
References: <4ED6BCEA.9050000@gmail.com> <4ED77E8E.2040304@RedHat.com> <4ED7B287.4010802@gmail.com>
In-Reply-To: <4ED7B287.4010802@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce Dubbs wrote:
> Steve Dickson wrote:

>> The reason you getting the mounting error to localhost is because 
>> there are no NFS services registered with rpcbind. Note the lack of 
>> nfs entires in
>> your rpcinfo -p output. For the above mount to work you would need at 
>> least the following entry:
> 
>>   100003    3   tcp   2049  nfs
> 
>> Figure out why that is not happening and you find the problem...

I got it to work.  I did a 'killall -HUP nfsd' and restarted 'rpc.nfsd 
-p 2049 8' and nfs showed up in rpcinfo and mount now works.

It must have been a sequence error on my part.  Sorry for the noise.

   -- Bruce
