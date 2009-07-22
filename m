From: Andy Adamson <andros@netapp.com>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Wed, 22 Jul 2009 18:26:09 -0400
Message-ID: <61F6C626-3C73-456A-A3A2-F1690C46914C@netapp.com>
References: <4A64EB1F.4000602@candelatech.com> <1248178527.5222.0.camel@heimdal.trondhjem.org> <4A65F184.5060802@candelatech.com> <1248196339.21343.8.camel@heimdal.trondhjem.org> <4A65FCB2.6080903@candelatech.com> <1248199140.21343.17.camel@heimdal.trondhjem.org> <4A660295.9020807@candelatech.com> <1248200897.21343.19.camel@heimdal.trondhjem.org> <4A6609A9.3000504@candelatech.com> <1248211050.21343.38.camel@heimdal.trondhjem.org> <A7103385-4525-4B7B-9CBA-5DBCB99A98F0@netapp.com> <1248294013.5234.35.camel@heimdal.trondhjem.org> <74713B5B-DF7F-4357-AE3A-0F6B44C41116@netapp.com> <1248299236.9202.3.camel@heimdal.trondhjem.org> <2CC45724-FD70-4F00-84F7-4D0E2158D6B5@netapp.com> <1248301062.9202.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Ben Greear <greearb@candelatech.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbZGVW0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 18:26:10 -0400
In-Reply-To: <1248301062.9202.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2009, at 6:17 PM, Trond Myklebust wrote:

> On Wed, 2009-07-22 at 18:03 -0400, Andy Adamson wrote:
>> On Jul 22, 2009, at 5:47 PM, Trond Myklebust wrote:
>>> Well.... The rsize/wsize is one thing, but how about acls? We simply
>>> don't know how big they may become.
>>
>> Yeah - has anything been submitted for 4.2 to fix this? (a readdir
>> cookie - like thingie)
>
> Not really. You pretty much have to set ACLs atomically, or you may  
> end
> up with security issues.

Sure, but we could help get ACL.

>
>
> The good news is, though, that we should be able to figure out an  
> upper
> limit by looking at the max_rqst_sz/max_resp_sz that the server  
> wants to
> set.

Yep.

-->Andy
>
>
>

