Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:4661 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943729AbcJaP0A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Oct 2016 11:26:00 -0400
Date: Mon, 31 Oct 2016 15:25:50 +0000
From: Jakub Kicinski <kubakici@wp.pl>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Yotam Gigi <yotamg@mellanox.com>, Andy Adamson <andros@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "Yotam Gigi" <yotam.gi@gmail.com>, mlxsw <mlxsw@mellanox.com>
Subject: Re: nfs NULL-dereferencing in net-next
Message-ID: <20161031152550.10acb7e0@jkicinski-Precision-T1700>
In-Reply-To: <DB3PR05MB0764F0409AE75E0172ABFE2EACAA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <20161017201943.64529739@jkicinski-Precision-T1700>
        <DB3PR05MB0764DF28BC53A4A4E78A4DD8ACA80@DB3PR05MB0764.eurprd05.prod.outlook.com>
        <817e43c5-d88d-e616-7074-5715de29d319@Netapp.com>
        <DB3PR05MB0764B39F6EDF851A8A52EBACACAB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
        <20161026190840.3d46dad8@jkicinski-Precision-T1700>
        <0ab5021c-84eb-cb9f-c7f5-4d856fdb0f4b@Netapp.com>
        <DB3PR05MB0764F0409AE75E0172ABFE2EACAA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 27 Oct 2016 06:50:22 +0000, Yotam Gigi wrote:
> >-----Original Message-----
> >From: Anna Schumaker [mailto:Anna.Schumaker@Netapp.com]
> >Sent: Wednesday, October 26, 2016 9:17 PM
> >To: Jakub Kicinski <kubakici@wp.pl>
> >Cc: Yotam Gigi <yotamg@mellanox.com>; Andy Adamson <andros@netapp.com>;
> >linux-nfs@vger.kernel.org; netdev@vger.kernel.org; Trond Myklebust
> ><Trond.Myklebust@netapp.com>; Yotam Gigi <yotam.gi@gmail.com>; mlxsw
> ><mlxsw@mellanox.com>
> >Subject: Re: nfs NULL-dereferencing in net-next
> >
> >On 10/26/2016 02:08 PM, Jakub Kicinski wrote:  
> >> On Wed, 26 Oct 2016 16:15:24 +0000, Yotam Gigi wrote:  
> >>>> -----Original Message-----
> >>>> From: Anna Schumaker [mailto:Anna.Schumaker@Netapp.com]
> >>>> Sent: Wednesday, October 26, 2016 5:40 PM
> >>>> To: Yotam Gigi <yotamg@mellanox.com>; Jakub Kicinski <kubakici@wp.pl>;  
> >Andy  
> >>>> Adamson <andros@netapp.com>; Anna Schumaker
> >>>> <Anna.Schumaker@Netapp.com>; linux-nfs@vger.kernel.org
> >>>> Cc: netdev@vger.kernel.org; Trond Myklebust  
> ><Trond.Myklebust@netapp.com>;  
> >>>> Yotam Gigi <yotam.gi@gmail.com>; mlxsw <mlxsw@mellanox.com>
> >>>> Subject: Re: nfs NULL-dereferencing in net-next
> >>>>
> >>>> On 10/25/2016 01:19 PM, Yotam Gigi wrote:  
> >>>>>  
> >>>>>> -----Original Message-----
> >>>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-  
> >owner@vger.kernel.org]  
> >>>> On  
> >>>>>> Behalf Of Jakub Kicinski
> >>>>>> Sent: Monday, October 17, 2016 10:20 PM
> >>>>>> To: Andy Adamson <andros@netapp.com>; Anna Schumaker
> >>>>>> <Anna.Schumaker@Netapp.com>; linux-nfs@vger.kernel.org
> >>>>>> Cc: netdev@vger.kernel.org; Trond Myklebust  
> >>>> <Trond.Myklebust@netapp.com>  
> >>>>>> Subject: nfs NULL-dereferencing in net-next
> >>>>>>
> >>>>>> Hi!
> >>>>>>
> >>>>>> I'm hitting this reliably on net-next, HEAD at 3f3177bb680f
> >>>>>> ("fsl/fman: fix error return code in mac_probe()").  
> >>>>>
> >>>>>
> >>>>> I see the same thing. It happens constantly on some of my machines, making  
> >>>> them  
> >>>>> completely unusable.
> >>>>>
> >>>>> I bisected it and got to the commit:
> >>>>>
> >>>>> commit 04ea1b3e6d8ed4978bb608c1748530af3de8c274
> >>>>> Author: Andy Adamson <andros@netapp.com>
> >>>>> Date:   Fri Sep 9 09:22:27 2016 -0400
> >>>>>
> >>>>>     NFS add xprt switch addrs test to match client
> >>>>>
> >>>>>     Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>>>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>  
> >>>>
> >>>> Thanks for reporting on this everyone!  Does this patch help?  
> >>>
> >>> Actually, I still see the same bug with the same trace.  
> >
> >Well, it was worth a shot.  I'll keep poking at it.
> >  
> >>
> >> I rebuild the latest net-next and I'm not seeing the trace any more...
> >> I'm only seeing this (with or without your patch):
> >>
> >> [   23.465877] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0
> >> [   23.473784] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0
> >> [   23.588890] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0
> >> [   23.596746] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0
> >> [   23.781574] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0
> >> [   23.789599] NFS: set_pnfs_layoutdriver: cl_exchange_flags 0x0  
> >
> >Interesting, I get that too when I try to use NFS v4.1.  It's weird that the crash would
> >stop happening like that, so maybe something is racy in this area.
> >
> >Thanks for testing, Yotam and Jakub!
> >Anna  
> 
> I just found out that it happens on any of my machines, once I put two nfs entries in
> my fstab. If I put only one, I don't see the problem. 
> 
> I hope it might be helpful :)

Hi Anna,

any updates on this one?  The crash came back half an hour after I
reported that it was gone...

Over the weekend David Miller rebased net-next on top of 4.9.0-rc3 and
the bug is still there :(  FWIW I also have multiple nfs mounts on my
setup, 2 in fstab and one in a startup script.  Following Yotam I
dropped one of the fstab entries and things seem to be working (even
though I still have multiple mounts, the other one just comes a bit
later).
