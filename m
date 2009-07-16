From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: Bug in server's export -- List of security flavors
Date: Thu, 16 Jul 2009 14:25:29 -0500
Message-ID: <4A5F7EA9.9050309@excfb.com>
References: <4A5F5C4C.3070308@excfb.com> <20090716185642.GB2495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao104.cox.net ([68.230.240.46]:51337 "EHLO
	eastrmmtao104.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439AbZGPTZq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2009 15:25:46 -0400
In-Reply-To: <20090716185642.GB2495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> I don't see how it could be a problem for the client to try an
> unadvertised flavor.  The server has to enforce the choice of flavor
> anyway.
>   

Yes, the server needs to enforce it, but why is the client trying a 
flavor that the server
says it does not support?



> (Um, but that's pretty weird that the server's advertising an empty
> list.  What's the nfs-utils version?)
>
>   


[tdh@adept root]> yum list nfs-utils
Loaded plugins: dellsysidplugin2, fastestmirror, refresh-packagekit
updates/metalink                                                                                                                       
| 2.9 kB     00:00
updates                                                                                                                                
| 4.4 kB     00:00
Installed Packages
nfs-utils.i586                                                            
1:1.1.5-6.fc11                                                             
installed


