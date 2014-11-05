Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbaKEUVj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 15:21:39 -0500
Message-ID: <545A86C1.4090809@RedHat.com>
Date: Wed, 05 Nov 2014 15:21:21 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chris Siebenmann <cks@cs.toronto.edu>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Best approach for authenticating hosts for NFS (v3)?
References: <20141105164555.3958A400746@apps1.cs.toronto.edu>
In-Reply-To: <20141105164555.3958A400746@apps1.cs.toronto.edu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/05/2014 11:45 AM, Chris Siebenmann wrote:
>> On 11/04/2014 11:53 AM, Chris Siebenmann wrote:
>>> PS: 'switch to NFS v4 to strongly authenticate user requests' is not an
>>>     option for us. We specifically value things that cannot be done
>>>     with true verification of user identification, like cron, and we
>>>     don't have and don't want to build the infrastructure that would
>>>     be required for strongly authenticated NFS v4.
>> The exact same "strongly authenticate" that in v4 is available
>> with v3. NFS secure mounts (-o krb5) are available 
>> with all NFS protocol versions.
>>
>> Tying NFS secure mounts with an FreeIPA environment should work
>> out well..    
> 
>  NFS v4 isn't the problem; strong authentication of user identities (and
> Kerberos) is the problem. Our environment and our users rely on the many
> forms that setuid takes[*] and as far as I know those are impossible with
> strong identification (in any NFS or remote filesystem protocol) because
> the point of strong authentication is that the server no longer trusts
> clients when they say 'honest, I'm working on behalf of uid <X>'.
Gotta... Interesting... I was just talking to a customer about 
this very problem...  Not being able to tie multiple GSS contexts 
to a single uid... 

steved.
> 
> (Instead the client must prove it by presenting a secret only the user
> is supposed to have access to, which the user must have somehow loaded
> on the client.)
> 
> 	- cks
> [*: including but not limited to crontabs, .forward files, user run web
>     apps and CGI-BINs, and detached processes left running for weeks.
> ]
> 
