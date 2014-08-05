Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tus1smtoutpex01.symantec.com ([216.10.195.241]:49756 "EHLO
	tus1smtoutpex01.symantec.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756006AbaHEHD6 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 03:03:58 -0400
From: Rishi Agrawal <Rishi_Agrawal@symantec.com>
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>,
        "bfields@redhat.com" <bfields@redhat.com>
Date: Mon, 4 Aug 2014 23:58:48 -0700
Subject: RE: Patch For Making Readdir_plus configurable
Message-ID: <20AEB6A025F81A4288597093171D1B571DBE0A7836@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <53DF992D.6090404@RedHat.com>
In-Reply-To: <53DF992D.6090404@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Regards,
Rishi Agrawal

-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Monday, August 04, 2014 8:01 PM
To: Rishi Agrawal; linux-nfs@vger.kernel.org
Cc: Rajesh Ghanekar; Ram Pandiri; Sreeharsha Sarabu; Abhijit Dey; Tushar Shinde; bfields@redhat.com
Subject: Re: Patch For Making Readdir_plus configurable

Hello,

On 25/07/14 12:19, Rishi Agrawal wrote:
> Hi,
>    One of our customer's application only needs file names not file 
> attributes. With directories having 10K+ inodes (assuming buffer cache 
> has directory blocks cached having file names, but inode cache is 
> limited and hence need eviction of older cached inodes), older inodes 
> are evicted periodically. So if they keep on doing
> readdir(2) from NSF client on multiple directories, some directory's 
> files are periodically removed from inode cache and hence new
> readdir(2) on same directory requires disk access to bring back inodes 
> again to inode cache.
> 
> As READDIRPLUS request fetches attributes also, doing getattr on each 
> file on server, it causes unnecessary disk accesses. If READDIRPLUS on 
> NFS client is returned with -ENOTSUPP, NFS client uses READDIR request 
> which just gets the names of the files in a directory, not attributes, 
> hence avoiding disk accesses on server.
> 
> Can this be per-export tunable so that different application can use 
> it in different ways, some supporting readdirplus and others not 
> supporting readdirplus?
> 
> I have worked on a patch against 3.15.6 for this. Also I am adding a 
> patch against latest nfs-utils to have an export option for this. Can 
> someone let me know if these patches are adequate or if any other 
> changes are required. Patches attached, although with minimal testing. 
> I would like to know if something like this can be added and if the 
> patch can be reworked if I am missing something for NFSv4.

I just notice that the nfs-utils patch does not update the exports(5) man page. In that update please note this is a v3 only thing.... Not clear what we are going to do in the v4 case.

Finally, please inline your patch posting in the your email as its is explained there
   https://www.kernel.org/doc/Documentation/SubmittingPatches

It just makes it easier for everyone to do the review... 

tia,

steved.
[[[Rishi]]] 

I will take care of the changes and resubmit the patch.

-- Rishi
