Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmpop111.cox.net ([68.230.240.53]:37640 "EHLO
	eastrmpop111.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758089Ab0HQSF1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 14:05:27 -0400
Message-ID: <4C6ACB70.7080409@excfb.com>
Date: Tue, 17 Aug 2010 12:48:32 -0500
From: Tom Haynes <tdh@excfb.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: =?UTF-8?B?VmljdG9yIE1hdGFyw6k=?= <dreck@vmsd.ath.cx>,
        linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803192241.GD31579@fieldses.org>
In-Reply-To: <20100803192241.GD31579@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 04:01:32AM +0200, Victor Mataré wrote:
>   
>> Hello,
>>
>> I still hope I'm mistaken in assuming I have to go back to NFSv3 if I want to 
>> skip NFSv4 UID mapping altogether and just use the numeric UIDs the way 
>> they're stored on-disk. However if that's actually true, I'd like to try and 
>> make a case for implementing an option to turn off UID mapping completely (or 
>> at least for unknown UIDs). If this is already work in progress, just ignore 
>> this mail.
>>
>> Thing is, the forced UID mapping seems to make tasks like backing up data a 
>> little inconvenient. You might want to preserve UIDs that are only known to 
>> the client.
>> But when you copy an entire root filesystem, it becomes outright destructive, 
>> because the rootfs will probably have several accounts that the server can't 
>> be expected know. Just imagine a server that's used for maintenance (like 
>> backing up and replacing hard drives) of random (foreign) systems. Idmapd will 
>> map all unknown UIDs to a single value and thereby destroy that information.
>>
>> I think I read somewhere
>>     
>
> Pointer?
>
>   

http://www.unix.com/man-page/OpenSolaris/4/nfs/

       If  a  domainname  is still not obtained following all of the preceding
       steps, nfsmapid will have no domain configured.	This  results  in  the
       following behavior:

	   o	  Outbound  "owner"  and  "owner_group"  attribute strings are
		  encoded as literal id's.  For  example,  the	UID  12345  is
		  encoded as 12345.

	   o	  nfsmapid   ignores  the  "domain"  portion  of  the  inbound
		  attribute string and performs name service lookups only  for
		  the  user  or  group.  If the user/group exists in the local
		  system name service databases, then the proper uid/gid  will
		  be mapped even when no domain has been configured.

		  This	 behavior   implies   that   the  same	administrative
		  user/group domain exists between  NFSv4  client  and	server
		  (that is, the same uid/gid's for users/groups on both client
		  and server). In the  case  of  overlapping  id  spaces,  the
		  inbound  attribute string could potentially be mapped to the
		  wrong id. However, this is not functionally  different  from
		  mapping  the	inbound string to nobody, yet provides greater
		  flexibility.





> --b.
>
>   
>> that the Sun people already have a way of handling 
>> this. Any chance Linux could do that, too?
>>
>> Please excuse me if I'm barking up the wrong tree. If this has already been 
>> discussed, I'd appreciate a pointer.
>>
>> Thanks,
>> Victor
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

