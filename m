Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45624 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab3FZTZH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 15:25:07 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Christopher T Vogan <cvogan@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Date: Wed, 26 Jun 2013 19:25:06 +0000
Message-ID: <1372274707.36780.2.camel@leira.trondhjem.org>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>
	 <1371568176.3868.5.camel@leira.trondhjem.org>
	 <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
	 <51CB3F08.9050005@RedHat.com>
In-Reply-To: <51CB3F08.9050005@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-06-26 at 15:20 -0400, Steve Dickson wrote:
> 
> On 18/06/13 15:59, Myklebust, Trond wrote:
> >> -----Original Message-----
> >> From: Christopher T Vogan [mailto:cvogan@us.ibm.com]
> >> Sent: Tuesday, June 18, 2013 3:56 PM
> >> To: Myklebust, Trond
> >> Cc: linux-nfs@vger.kernel.org
> >> Subject: Re: NFSERR_STALE on umount with 3.10.0.RC5 kernel
> >>
> >> The NFS server uses UMNT as a signal to remove the client from its mount
> >> table. Also at this time the Server cleans up other information about the now
> >> disconnected client.  Why would the client attempt to access the NFS server
> >> once it has stated its going to unmount?  I do not see the point of the
> >> GETATTR request after UMNT call.
> > 
> > As I said, the umount.nfs utility is doing the umount system call after UMNT, so the 
> > client does a lookup of the umount path at that time.
> > 
> > IOW: This has nothing to do with the kernel. If you feel it is a bug, then please ask 
> > SteveD to file a fix against nfs-utils.
> > 
> I just took a look at the umount code and it appears the UMNT call and 
> umount() system call are being done in the correct order... 
> 
> The UMNT call is done in nfs_umount23() which is follow by either
> mnt_context_do_umount() (if using the libmount code) or del_mtab()
> which make the umount() system call....

That's the order that will cause the result Christopher is seeing: first
a UMNT call, then a lookup/revalidate as part of the umount() system
call.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
