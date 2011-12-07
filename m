Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757945Ab1LGQau (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 11:30:50 -0500
Message-ID: <4EDF94AE.10302@RedHat.com>
Date: Wed, 07 Dec 2011 11:30:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Harald Dunkel <harri@afaics.de>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 fsid=0 export still necessary?
References: <4EDA0650.9080702@afaics.de> <4EDA5387.5070103@RedHat.com> <20111206011007.GD3678@fieldses.org>
In-Reply-To: <20111206011007.GD3678@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/05/2011 08:10 PM, J. Bruce Fields wrote:
> On Sat, Dec 03, 2011 at 11:51:19AM -0500, Steve Dickson wrote:
>> No, the fsid=0 export option is no longer necessary to make v4
>> exports compatible with v2/v3 exports. When the fsid option
>> is not set, the default root is define as "/" which allows
>> the v4 clients to mount the same exports as does the v2/v3 clients.
>>
>> Now if you do not what "/" as your default root, you can
>> set fsid to something like fsid=/export. This will
>> change to default root to the /export directory which
>> means your v4 clients will only be able to access exports
>> under the /export directory. 
> 
> I actually have some old patches that allow you to use an alternate root
> for all NFS versions; you'd do something like:
> 
> 	/exports	*(ro, root)
> 	/exports/foo	*(rw)
> 	/exports/bar	*(rw)
> 
> and then a v2, v3, or v4 client would mount server:/foo or server:/bar.
> 
> But that was just a fun project, it wasn't clear to me whether anyone
> wanted it particularly.
> 
> Also, that didn't seem like a great user interface.  I'd rather have
> something like
> 
> 	rootpath=/exports
> 	foo	*(rw)
> 	bar	*(rw)
> 
> Actually, as long as we were doing that I'd rather replace /etc/exports
> entirely; maybe do something like
> 
> 	[nfsd]
> 		rootpath=/exports
> 	[export "foo"]
> 		clients=*
> 		options=rw
> 	[exports "bar"]
> 		clients=*
> 		options=rw
> 
> And also use the same file for other nfsd parameters:
> 
> 	[nfsd]
> 		versions=2,3,4,4.1
> 		threads=8
> 		rootpath=/exports
> 	[export "foo"]
> 		...
I kinda like this idea... In the systemd world, its less
error prone to have daemons read their own configuration 
files... 

Where would this new file live and what would be called?

steved.
