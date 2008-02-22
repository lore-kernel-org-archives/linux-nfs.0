From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Fri, 22 Feb 2008 21:03:22 +0100
Message-ID: <47BF2A8A.9030002@foo-lounge.de>
References: <47BCA119.2030404@foo-lounge.de>	<18364.64328.189954.417159@notabene.brown>	<47BD5DFA.8080200@foo-lounge.de> <18366.5777.25957.73691@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:49252 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933556AbYBVUDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2008 15:03:32 -0500
In-Reply-To: <18366.5777.25957.73691-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Thursday February 21, mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org wrote:
>>> You could always build your own nfs-utils and configure with
>>> --without-uuid.
>>>
>>> Not an ideal solution...
>> What would be the downside of that solution? I suppose NFS would keep on
>> working even if I disabled that switch, but you gave the impression
>> there was some (major) drawback.
>>
> 
> The fact that you have to compile your own tools rather than just use
> what the distro provides is always a bit of a bore.
> 
> Also, if you change the server to stop using UUIDs, then any clients
> which have the filesystem mounted will need to remount as the old
> mount will become stale.
> 
> So it isn't a major problem, but nor is it an ideal solution.

Is there a proper place to file a bug report for this issue? I'm lacking
the expertise to know whose responsibility it is, but I remember you
mentioned libblkid before.


--Timo
