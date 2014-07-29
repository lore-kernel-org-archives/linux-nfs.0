Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385AbaG2Ueu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jul 2014 16:34:50 -0400
Date: Tue, 29 Jul 2014 16:34:49 -0400
To: Rishi Agrawal <Rishi_Agrawal@symantec.com>
Cc: Christopher T Vogan <cvogan@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: Patch For Making Readdir_plus configurable
Message-ID: <20140729203449.GE21091@fieldses.org>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <OF57CEB932.B84FFC9B-ON87257D20.005C9233-86257D20.005CC28D@us.ibm.com>
 <20AEB6A025F81A4288597093171D1B571DBDB8FA43@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20AEB6A025F81A4288597093171D1B571DBDB8FA43@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 27, 2014 at 08:17:26PM -0700, Rishi Agrawal wrote:
> Hi Christopher,
> 
> Customer is having mixed of NFS client OS setups and having this at server side would help to avoid having each client mount with this option. 

I'm happy to take the client nordirplus option as evidence this is
useful in some cases, and wanting to have a way to turn it on across all
clients seem reasonable.

One concern is that this is NFSv3-only for now and it may be difficult
to implement comparable behavior on NFSv4.

But absent any objections I'm inclined to apply for 3.17 regardless and
deal with NFSv4.0 if and when it becomes a problem.

--b.

> 
> 
> From: Christopher T Vogan [mailto:cvogan@us.ibm.com] 
> Sent: Friday, July 25, 2014 10:23 PM
> To: Rishi Agrawal
> Cc: linux-nfs@vger.kernel.org; Rajesh Ghanekar; Ram Pandiri; Sreeharsha Sarabu; Abhijit Dey; Tushar Shinde; bfields@redhat.com; steved@redhat.com
> Subject: Re: Patch For Making Readdir_plus configurable
> 
> There is a client side option "nordirplus" which can be used to force the client to use READDIR 
> 
> 
> Christopher Vogan
> NFS Development & Test 
> 
> 
> 
> From:        Rishi Agrawal <Rishi_Agrawal@symantec.com> 
> To:        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org> 
> Cc:        Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>, Ram Pandiri <ram_pandiri@symantec.com>, Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>, Abhijit Dey <Abhijit_Dey@symantec.com>, Tushar Shinde <Tushar_Shinde@symantec.com>, "bfields@redhat.com" <bfields@redhat.com>, "steved@redhat.com" <steved@redhat.com> 
> Date:        07/25/2014 11:24 AM 
> Subject:        Patch For Making Readdir_plus configurable 
> Sent by:        linux-nfs-owner@vger.kernel.org 
> ________________________________________
> 
> 
> 
> Hi,
>    One of our customer's application only needs file names not
> file attributes. With directories having 10K+ inodes (assuming buffer
> cache has directory blocks cached having file names, but inode
> cache is limited and hence need eviction of older cached inodes),
> older inodes are evicted periodically. So if they keep on doing
> readdir(2) from NSF client on multiple directories, some directory's
> files are periodically removed from inode cache and hence new
> readdir(2) on same directory requires disk access to bring back
> inodes again to inode cache.
> 
> As READDIRPLUS request fetches attributes also, doing getattr on
> each file on server, it causes unnecessary disk accesses. If
> READDIRPLUS on NFS client is returned with -ENOTSUPP, NFS
> client uses READDIR request which just gets the names of the files
> in a directory, not attributes, hence avoiding disk accesses on server.
> 
> Can this be per-export tunable so that different application can
> use it in different ways, some supporting readdirplus and others
> not supporting readdirplus?
> 
> I have worked on a patch against 3.15.6 for this. Also I am
> adding a patch against latest nfs-utils to have an export option
> for this. Can someone let me know if these patches are adequate
> or if any other changes are required. Patches attached, although
> with minimal testing. I would like to know if something like this
> can be added and if the patch can be reworked if I am missing
> something for NFSv4.
> 
> 
> Regards,
> Rishi Agrawal
> 
> 
> [attachment "patch_linux-kernel-3-15-6" deleted by Christopher T Vogan/San Jose/IBM] [attachment "patch_nfs-utils-1.3" deleted by Christopher T Vogan/San Jose/IBM] 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
