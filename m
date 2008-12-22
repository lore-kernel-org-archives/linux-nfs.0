Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:58586 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbYLVUgO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2008 15:36:14 -0500
Received: by nf-out-0910.google.com with SMTP id d3so299605nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 22 Dec 2008 12:36:12 -0800 (PST)
Message-ID: <a92ebfd90812221236g7250f256n5b58b5ff5ce47403@mail.gmail.com>
Date: Mon, 22 Dec 2008 20:36:12 +0000
From: "James Pearson" <james-p@moving-picture.com>
Reply-To: james-p@moving-picture.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with Mac clients mounting a Linux server behind a firewall
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20081222172309.GO4191@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
References: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com>
	 <494FC625.4040207@moving-picture.com>
	 <20081222172309.GO4191@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2008/12/22 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Dec 22, 2008 at 04:53:57PM +0000, James Pearson wrote:
>
>>> Is there anything that NFS server-wise that could be cause the server
>>> to attempt to contact clients in this way?
>>
>> Running wireshark over the tcpdump output, all these portmap calls are like:
>>
>> User Datagram Protocol, Src Port: 51947 (51947), Dst Port: sunrpc (111)
>> Remote Procedure Call, Type:Call XID:0xacd4150f
>> Portmap GETPORT Call NLM(100021) Version:4 UDP
>>     [Program Version: 2]
>>     [V2 Procedure: GETPORT (3)]
>>     Program: NLM (100021)
>>     Version: 4
>>     Proto: UDP (17)
>>     Port: 0
>>
>> Why would an NFS server need to initiate a call to the lockd process on
>> a (MacOS) client?
>
> The communication between lockd's is 2-way, so that, for example,
> servers can notify clients when locks are available.  Also, the server's
> statd needs to contact the clients so it can ask the clients to notify
> it when the clients reboot (and hence when their file locks should be
> released).  And similarly the server needs to be able to notify the
> clients when it reboots, so the client can reclaim any locks it
> previously held.
>
> So your firewall settings are a problem.  But, obviously, we should be
> handling this more gracefully on the server.

Thanks for the explanation - however, I never come across this
requirement before with NFS servers behind firewalls - for example,
RedHat's documentation at <http://kbase.redhat.com/faq/docs/DOC-3259>
says the usual stuff about fixing the ports of various portmap
services for the server and opening those ports for traffic to the
server through the firewall - but no mention of the server needing to
talk to the portmapper and lockd on the clients ... and I can't see
how this would work as the portmapper port and any possible lockd port
will have to be open on the firewall from server to all clients ...

Also, it is strange that this problem only happens with MacOS clients
- I've never see the server trying to talk to Linux clients in this
way. So I guess it is something that the MacOS clients do differently
...

Is there any way I can configure the server to ignore locking
completely? e.g. turn off statd?

Thanks

James Pearson
