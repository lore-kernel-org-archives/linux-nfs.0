Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:47150 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab2BBLav (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 06:30:51 -0500
Message-ID: <4F2A74A7.4060905@steve-ss.com>
Date: Thu, 02 Feb 2012 12:33:59 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: tigran.mkrtchyan@desy.de
Subject: nfs4 keytabs  [was:Re: where can I ask user qns about nfs4]?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
In-Reply-To: <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/02/12 11:58, Tigran Mkrtchyan wrote:
> Hi Steve,
>
>>
>> I already use nfs4 to serve my Linux clients. I'm going to kerberize it. My
>> clients already have machine and host principals. What else do they need?
>>
>> 1. nfs/client.domain.name
>> 2. nfs/server.domain/name
>> 3. neither
>> 4. both
>>
>
> We run kerberized NFS.
>
> our keytab contains:
>
> on server;
>    nfs/server.domain
>
> on client:
>    nfs/client.domain
>
> and, of course, you need a consistent  idmap configuration.
>
> Tigran.
>
Hi Tigran

That's what we have on our test lan at the moment. I can understand that 
the server would need the service principal:
    nfs/server.domain
but not the client, as it's not offering any kerberized service.

As an experiment, I removed the nfs/client.domain from a client keytab, 
rebooted and remounted the share. We could still access the kerberized 
nfs share. Maybe there were still some tickets left somewhere? That has 
me really confused.

And yes, we found out very early on that idmapd had to be running at 
both ends.

Thanks for the reply. You've got me thinking.
Steve
