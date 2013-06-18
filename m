Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:9876 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932908Ab3FRT7t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 15:59:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christopher T Vogan <cvogan@us.ibm.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Date: Tue, 18 Jun 2013 19:59:47 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
 <1371568176.3868.5.camel@leira.trondhjem.org>
 <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
In-Reply-To: <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Christopher T Vogan [mailto:cvogan@us.ibm.com]
> Sent: Tuesday, June 18, 2013 3:56 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFSERR_STALE on umount with 3.10.0.RC5 kernel
> 
> The NFS server uses UMNT as a signal to remove the client from its mount
> table. Also at this time the Server cleans up other information about the now
> disconnected client.  Why would the client attempt to access the NFS server
> once it has stated its going to unmount?  I do not see the point of the
> GETATTR request after UMNT call.

As I said, the umount.nfs utility is doing the umount system call after UMNT, so the client does a lookup of the umount path at that time.

IOW: This has nothing to do with the kernel. If you feel it is a bug, then please ask SteveD to file a fix against nfs-utils.

Cheers
  Trond

 
> Christopher Vogan
> Dept. W98 NFS Development & Test
> 
> 
> 
> From:   "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> To:     Christopher T Vogan/San Jose/IBM@IBMUS,
> Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> Date:   06/18/2013 10:19 AM
> Subject:        Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
> 
> 
> 
> On Tue, 2013-06-18 at 07:47 -0600, Christopher T Vogan wrote:
> > The new linux 3.10.0-rc5 kernel gets NFSERR_STALE on un-mount.
> > The reason is the Linux client is sending a GETATTR after the umnt
> > call/reply.
> > This is a network trace of the umnt call/reply and the gettattr
> > afterwords.
> 
> This happens because the 'umount.nfs' utility calls the umnt RPC before the
> actual umount system call.
> 
> Why would this trigger an NFSERR_STALE? Is the server using UMNT for
> something other than just providing client usage stats? If so, what and why?
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> 

