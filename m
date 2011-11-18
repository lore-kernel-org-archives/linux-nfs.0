Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3.ugent.be ([157.193.49.127]:57463 "EHLO smtp3.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756797Ab1KRO52 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Nov 2011 09:57:28 -0500
Message-ID: <4EC67021.6060905@debian.org>
Date: Fri, 18 Nov 2011 15:48:01 +0100
From: Luk Claes <luk@debian.org>
MIME-Version: 1.0
To: John Hughes <john@Calva.COM>
CC: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry
References: <4EC6426A.3020306@Calva.COM> <4EC66148.4020003@RedHat.com> <4EC664D3.9030402@Calva.COM>
In-Reply-To: <4EC664D3.9030402@Calva.COM>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2011 02:59 PM, John Hughes wrote:
> On 18/11/11 14:44, Steve Dickson wrote:
>>
>> On 11/18/2011 06:32 AM, John Hughes wrote:

>> . Plus there is no man page update...
> 
> Okeydoke, let's see, where's the man page...
> 
> $ find  /usr/share/man* -name 'rcp.gssd*'
> 
> find: cannot get current directory: Permission denied

rcp != rpc

Cheers

Luk
