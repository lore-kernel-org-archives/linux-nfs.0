Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:55089 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab1KROAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 09:00:04 -0500
Message-ID: <4EC664D3.9030402@Calva.COM>
Date: Fri, 18 Nov 2011 14:59:47 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry
References: <4EC6426A.3020306@Calva.COM> <4EC66148.4020003@RedHat.com>
In-Reply-To: <4EC66148.4020003@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/11/11 14:44, Steve Dickson wrote:
>
> On 11/18/2011 06:32 AM, John Hughes wrote:
>> By adding a new option to rpc.gssd the administrator can choose whether she wants the old "EACCESS on ticket expiry" or the new "wait for new ticket" behaviour.
>>
>>
> I am not too keen this idea at all.... I've never been a fan of
> added command line arguments for this purpose..

Nope, me neither.

> . Plus there is no man page update...

Okeydoke, let's see, where's the man page...

$ find  /usr/share/man* -name 'rcp.gssd*'

find: cannot get current directory: Permission denied


AArgh!  :-)  Yum, this dogfood tastes nice!

> Also please post patches in-line
> the email not as email attachments...

De gustibus non disputandum est.

New version of patch on it's way.


