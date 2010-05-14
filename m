From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6 support in pNFS
Date: Fri, 14 May 2010 13:49:35 -0400
Message-ID: <4BED8D2F.30205@oracle.com>
References: <4BED89E2.8070903@atlas.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jiri Kortus <sumix-a4qEbw8STSk@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:60029 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758605Ab0ENRuj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 13:50:39 -0400
In-Reply-To: <4BED89E2.8070903-a4qEbw8STSk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/14/10 01:35 PM, Jiri Kortus wrote:
> Hi,
>
> I'm sorry to flood the mailing list by repeating my question several
> times - I've already asked whether someone would be so kind as to tell
> me something about the situation of IPv6 support in pNFS. Just anything
> related to it would be appreciated very much since nobody gave me an
> answer (except Boaz Harrosh who wrote me about the IPv6 absence in OSD
> target). I'd like to know whether there's any support for IPv6
> (concerning all of the layouts available), if yes what are the issues
> with that, if not when the implementation is planned to start etc. I did
> google that a lot before asking but haven't found anything. Thanks very
> much in advance.

I implemented IPv6 support in the rest of Linux NFS, but since the Linux 
pNFS implementation  is still under development, I haven't looked at 
supporting IPv6 in pNFS.
