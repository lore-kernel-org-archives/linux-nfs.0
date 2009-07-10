Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao106.cox.net ([68.230.240.48]:54144 "EHLO
	eastrmmtao106.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbZGJU4L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 16:56:11 -0400
Message-ID: <4A57AADE.8080002@excfb.com>
Date: Fri, 10 Jul 2009 15:55:58 -0500
From: Tom Haynes <tdh@excfb.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Security negotiation
References: <4A578372.1020005@excfb.com> <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com> <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>
In-Reply-To: <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
>
>>
>> If mountd does not provide AUTH_SYS a mount request with no sec= will 
>> fail.  Should it try the first one in the list instead?  What if the 
>> first one is AUTH_NULL?
>
> In other words, I'm not sure what is the right behavior here.  What it 
> does now is probably suboptimal.  I've browsed 2623 a bit, but it's 
> not hitting me.
>

So we (OpenSolaris) changed our behavior inadvertently to do the
list in order. Which means we are trying AUTH_NONE against
a Linux server. (Bug is here: 
http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6834430)

We are considering two changes:

1) Use our default flavor (user configurable)
2) Order the list by strength based on the flavors we support.

The first option would get us to where you are going to be. AUTH_SYS will
probably be the default.

The second option would push AUTH_NONE to the end of the list, which
corresponds to my thinking of it as a wild card.

But it also means that if AUTH_SYS is not our default, then we might try
Kerberized access first. I think that is a surprise.

Also, if the server has already ordered the list based on the preference it
would like the client to try, then the client should honor that list if no
specific flavor is used.

So, I would say algorithmically:

1) If the client specifies a flavor, it uses that if the server supports 
it. If the
server does not, the mount fails.

2) If the client has a default, it tries that first if the server 
supports it. If the
server does not, then:

3) The client walks the array of flavors and uses the first that it supports
and the server supports.

