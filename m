From: Kyle Rose <krose@krose.org>
Subject: Re: READDIRPLUS max mount option
Date: Fri, 07 Mar 2008 15:09:25 -0500
Message-ID: <47D1A0F5.2070501@krose.org>
References: <47D1995E.6060501@krose.org> <1204919978.16746.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763970AbYCGUJh@vger.kernel.org>
In-Reply-To: <1204919978.16746.12.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The binary mount format is frozen forever, so the changes to nfs_mount.h
> and nfs4_mount.h are definitely NACKed.
>   
Ah. :-)  So is there no way to add mount options, or is there a 
different mechanism today?
> Otherwise, it would be nice to know why this absolutely has to be made a
> mount option rather than just having a system-wide option (either a
> module/boot parameter or a sysctl) to control the behaviour of all
> mounts.
>   
I mount multiple remote file systems.  Only one of them I own, so I'm 
willing to potentially hammer it with huge READDIRPLUS requests, while 
the others probably deserve more benign behavior. ;-)

In general, I think having system-wide defaults somewhere in proc is 
helpful---and certainly superior to a constant in the source---but there 
should really be mount-specific overrides wherever the system-wide 
default might not be globally appropriate.

Kyle
