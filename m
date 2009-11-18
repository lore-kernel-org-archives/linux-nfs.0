From: Christopher Metter
	<christopher.metter-jNDFPZUTrfSeRcrpBB1ZFQkon6kHRKkiG9Ur7JDdleE@public.gmane.org>
Subject: Re: Problems Migrating from NFSv3 to NFSv4
Date: Wed, 18 Nov 2009 13:02:16 +0100
Message-ID: <4B03E248.4050002@informatik.uni-wuerzburg.de>
References: <4B01A0B5.80501@informatik.uni-wuerzburg.de> <4B02AF7D.4090503@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailscanner1.rox.net ([213.214.0.46]:49483 "EHLO
	mailscanner1.rox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbZKRMCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Nov 2009 07:02:54 -0500
In-Reply-To: <4B02AF7D.4090503-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson schrieb:
>> My Question is:
>> What do i have to do, that even if im mounting Servers root, I only can
>> see and access the specificly for this client configurated exports?
>> (Also with correct access, of course)
>>     
> I'm not sure I understand your question... Are you asking is there a 
> way for clients to only see particular directories on a the server's root?
>
> steved.
>
>   
Hi Steve,

thats what im talking about. 
Clients should only see(+write) particular directories on the server, 
after I've set the permission for this.

Example:

/srv/data  is NFSv4Root and includes:
/srv/data/folder1
/srv/data/folder2
/srv/data/folder3

Now I set permission for Client1 to readonly folder1 and readwrite 
folder2 and no permissions for folder3.

After mounting servers root, I only see folder1 and only can write in 
folder2. And the Client doesnt know anything about folder3
