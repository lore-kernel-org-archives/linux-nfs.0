From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kerberos authentication Problem with nfs3/4
Date: Sun, 19 Oct 2008 15:50:37 -0400
Message-ID: <20081019195037.GC8647@fieldses.org>
References: <20081018153037.GA27982@fieldses.org> <14393409-84DC-42C1-9680-32A2B81A27BA@it-loops.com> <28F249B0-91A5-4EA5-A12E-F6258B240EDB@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbYJSTuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2008 15:50:39 -0400
In-Reply-To: <28F249B0-91A5-4EA5-A12E-F6258B240EDB-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 18, 2008 at 07:46:21PM +0200, Guntsche Michael wrote:
>
> On Oct 18, 2008, at 17:59, Guntsche Michael wrote:
>
>>
>>>
>>> nfsv4@linux-nfs.org or linux-nfs@vger.kernel.org would be the right
>>> place to ask about this.
>>>
>>> Is it possible you could be hitting this?:
>>>
>>> 	http://linux-nfs.org/pipermail/nfsv4/2008-October/009365.html
>>
>> Apparently this never made it to the list, but only to myself and  
>> Bruce :)
>>
>> Coming back to the problem. In my case the domain name and realm are  
>> the same. I'll try to find out, where the problem is triggered  
>> exactly.
>>
>
> Ok, the problem has been solved. It was a configuration error afterall. 
> The problem was that per default this was set in idmapd.conf
>
> Domain = localdomin
>
> The new version if the library read this one first and of course this  
> led to problems. There are two possible solutions here.
>
> * Change the Domain entry in the config file
> * Remove the entry, then a DNS lookup is made
>
> In both cases mounting the export with krb5 works without any problems.
>
> Sorry for putting so much noise on the list.

It looks like the most recent commit cfc6246a43... from
git://git.linux-nfs.org/projects/kwc/libnfsidmap.git sets the default to
get the domain from DNS, so hopefully this will be more likely to work
out of the box in the future.

--b.
