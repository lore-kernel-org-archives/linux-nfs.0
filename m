From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in server's export -- List of security flavors
Date: Thu, 16 Jul 2009 15:45:46 -0400
Message-ID: <20090716194546.GG2495@fieldses.org>
References: <4A5F5C4C.3070308@excfb.com> <20090716185642.GB2495@fieldses.org> <4A5F7EA9.9050309@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41681 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932952AbZGPTpq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 15:45:46 -0400
In-Reply-To: <4A5F7EA9.9050309-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2009 at 02:25:29PM -0500, Tom Haynes wrote:
> J. Bruce Fields wrote:
>> I don't see how it could be a problem for the client to try an
>> unadvertised flavor.  The server has to enforce the choice of flavor
>> anyway.
>>   
>
> Yes, the server needs to enforce it, but why is the client trying a  
> flavor that the server
> says it does not support?

Could just be excessively persistent of optimistic.  (Or in this case
probably it just doesn't have any negotiation code, so it's simplest
just to try the one flavor that was specified on the mount; seems fair
to me.)

There's also cases where this could also happen just due to bad timing:
maybe the export got changed in the middle.  If only for that reason, I
don't think we could forbid a client from doing this.

>> (Um, but that's pretty weird that the server's advertising an empty
>> list.  What's the nfs-utils version?)
>>
>>   
>
>
> [tdh@adept root]> yum list nfs-utils
> Loaded plugins: dellsysidplugin2, fastestmirror, refresh-packagekit
> updates/metalink                                                          
>                                                              | 2.9 kB     
> 00:00
> updates                                                                   
>                                                              | 4.4 kB     
> 00:00
> Installed Packages
> nfs-utils.i586                                                            
> 1:1.1.5-6.fc11                                                            
>  installed

Thanks!

Hm.  So this change of mine:

	603017f2c1587d760e2649b889b581ca267ffee7 "Determine supported
	pseudoflavors from export"

is probably at fault.  I guess we need to figure out why it's producing
a zero-length array.

--b.
