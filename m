Return-Path: linux-nfs-owner@vger.kernel.org
Received: from office2.cesnet.cz ([195.113.144.244]:56768 "EHLO
	office2.cesnet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab2GVUku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jul 2012 16:40:50 -0400
Message-ID: <500C63B8.2030200@gmail.com>
Date: Sun, 22 Jul 2012 22:34:00 +0200
From: Jiri Horky <jiri.horky@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org, "du@cesnet.cz" <du@cesnet.cz>
Subject: Re: idmapd client-side static mapping
References: <4FFED6FA.4070407@cesnet.cz> <4FFEE612.8060406@RedHat.com>
In-Reply-To: <4FFEE612.8060406@RedHat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I sent the patch in the separated email and now I hope for the best :)

Some more notes: if one configures only the "Static" translation method 
nowadays, any translation of id to name does not occur (since it is not 
implemented), return code of the nfs4_uid_to_name() function will be 0 
which is set by init function in libnfsidmap.c:357 and you get empty 
string as the result which puzzles the client and completely freezes the 
system. It can be triggered by e.g. issuing "chown 1000 /nfs4mnt/testfile".
I think that more correct behavior would be to return -ENOENT if there 
are no plugins with a given translation function. This is not included 
in the patch sent.

By the way, is there a reason why the function like nfs4_name_to_uid or 
its "gid" partner does not return "nobody/nogroup" when it fails to do 
the translation? On my system, it is set to a random value 
(uninitialized int) in this case.

Jiri Horky





On 07/12/2012 04:58 PM, Steve Dickson wrote:
> On 07/12/2012 09:54 AM, Jiri Horky wrote:
>> Hi,
>>
>> man pages for idmapd.conf states possibility to use Static mapping. Looking at the source code of libnfsidmap v0.24, it is clear that static mappings are only valid for server side (svcgssd) which the man page forgets to mention. Is there any specific reason why not to implement the static resolution functions on the client side as well?
> That is a good question... I always wonders this myself....
>
>> I would send a patch if there is a change it will be accepted.
> There is only one way to find out! ;-)
>
> steved.
