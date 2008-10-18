From: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Re: Kerberos authentication Problem with nfs3/4
Date: Sat, 18 Oct 2008 19:46:21 +0200
Message-ID: <28F249B0-91A5-4EA5-A12E-F6258B240EDB@it-loops.com>
References: <20081018153037.GA27982@fieldses.org> <14393409-84DC-42C1-9680-32A2B81A27BA@it-loops.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@citi.umich.edu
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:47845
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbYJRRq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2008 13:46:27 -0400
In-Reply-To: <14393409-84DC-42C1-9680-32A2B81A27BA-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 18, 2008, at 17:59, Guntsche Michael wrote:

>
>>
>> nfsv4@linux-nfs.org or linux-nfs@vger.kernel.org would be the right
>> place to ask about this.
>>
>> Is it possible you could be hitting this?:
>>
>> 	http://linux-nfs.org/pipermail/nfsv4/2008-October/009365.html
>
> Apparently this never made it to the list, but only to myself and  
> Bruce :)
>
> Coming back to the problem. In my case the domain name and realm are  
> the same. I'll try to find out, where the problem is triggered  
> exactly.
>

Ok, the problem has been solved. It was a configuration error  
afterall. The problem was that per default this was set in idmapd.conf

Domain = localdomin

The new version if the library read this one first and of course this  
led to problems. There are two possible solutions here.

* Change the Domain entry in the config file
* Remove the entry, then a DNS lookup is made

In both cases mounting the export with krb5 works without any problems.

Sorry for putting so much noise on the list.

Kind regards,
Michael
