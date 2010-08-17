From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] Support for Numeric Representations of UIDs and GIDs.
Date: Tue, 17 Aug 2010 15:30:35 -0500
Message-ID: <4C6AF16B.2010807@excfb.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com> <4C6AE85E.4000305@excfb.com> <4C6AEB43.5080508@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao106.cox.net ([68.230.240.48]:54952 "EHLO
	eastrmmtao106.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab0HQUb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 16:31:29 -0400
In-Reply-To: <4C6AEB43.5080508-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> On 08/17/2010 03:51 PM, Tom Haynes wrote:
>   
>> Steve Dickson wrote:
>>     
>>> In recent NFS v2/v3 to v4 transitions, one of the sticking points have been that fact v4 uses strings in the format
>>> of "user@domain" instead of 32bit integers for uids and gids.
>>>
>>> When the string can not be mapped, its mapped to the 'nobody'
>>> user which is not optimal for things like backup servers and
>>> such where the ids will not be know by both sides.
>>>
>>> So this patch series enables the server to send out numeric string of uids and gids that do not have the '@domain' part.
>>> The series also adds functionality to the client that parse these
>>> type of strings and will use the numeric representation
>>> of the ids iff the id exists on the client, which is sightly different that Solaris. Solaris dose not have that
>>> "id must exist" restriction.
>>>   
>>>       
>> No, Solaris does have that restriction.
>>     
> I thought so too.... but when I had an Open Solaris client 
> access an directory, on a Linux server, that was owned by a 
> user that was non-existent on either the server or client, 
> I got the numeric representation as the owner.... 
> Basically:
>
> osol# mount Linux-server:/home /mnt/home
> osol# ls -ld /mnt/home/noid
> drwxr-xr-x+  2 111      111         4096 Aug 17 11:37 /mnt/home/noid/
> osol# grep 111 /etc/passwd
> osol#
>
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

That is what I get for reading code instead of running it. :->

Actually, it might be that the server acts that way and not the client.
