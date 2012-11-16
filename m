Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42882 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab2KPCYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 21:24:49 -0500
Date: Thu, 15 Nov 2012 21:24:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
Message-ID: <20121116022447.GB23409@fieldses.org>
References: <20121016125832.GC30649@fieldses.org>
 <20121024200249.GC6697@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092906F7@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024201517.GD6697@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90929086C@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024204059.GF6697@fieldses.org>
 <20121028161556.GC20520@fieldses.org>
 <490C84A9-2764-4E35-893E-727853B12916@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <490C84A9-2764-4E35-893E-727853B12916@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 15, 2012 at 09:03:03PM -0500, Chuck Lever wrote:
> 
> On Oct 28, 2012, at 12:15 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Wed, Oct 24, 2012 at 04:40:59PM -0400, J. Bruce Fields wrote:
> >> On Wed, Oct 24, 2012 at 08:34:37PM +0000, Myklebust, Trond wrote:
> >>>> -----Original Message-----
> >>>> From: Myklebust, Trond
> >>>> Sent: Wednesday, October 24, 2012 4:31 PM
> >>>> To: 'J. Bruce Fields'
> >>>> Cc: linux-nfs@vger.kernel.org; Schumaker, Bryan
> >>>> Subject: RE: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> >>>> 
> >>>>> -----Original Message-----
> >>>>> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> >>>>> Sent: Wednesday, October 24, 2012 4:15 PM
> >>>>> To: Myklebust, Trond
> >>>>> Cc: linux-nfs@vger.kernel.org; Schumaker, Bryan
> >>>>> Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> >>>>> 
> >>>>> On Wed, Oct 24, 2012 at 08:07:55PM +0000, Myklebust, Trond wrote:
> >>>>>>> -----Original Message-----
> >>>>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> >>>>>>> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> >>>>>>> Sent: Wednesday, October 24, 2012 4:03 PM
> >>>>>>> To: linux-nfs@vger.kernel.org; Myklebust, Trond; Schumaker, Bryan
> >>>>>>> Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> >>>>>>> 
> >>>>>>> Anyone get a chance to look at this?  It seems very reproduceable.
> >>>>>>> 
> >>>>>>> --b.
> >>>>>>> 
> >>>>>>> On Tue, Oct 16, 2012 at 08:58:32AM -0400, bfields wrote:
> >>>>>>>> On 3.7-rc1:
> >>>>>>>> 
> >>>>>>>> 	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4
> >>>>>>>> /mnt/
> >>>>>>>> 
> >>>>>>>> 		server# ls -l /exports/ext4|grep TMP
> >>>>>>>> 		server#
> >>>>>>>> 
> >>>>>>>> 	# mkdir /mnt/TMP
> >>>>>>>> 	mkdir: cannot create directory `/mnt/TMP': Permission denied
> >>>>>>>> 
> >>>>>>>> 		server# ls -l /exports/ext4|grep TMP
> >>>>>>>> 		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
> >>>>>>>> 		server#
> >>>>>>>> 
> >>>>>>>> Wireshark also shows that the create succeeds.
> >>>>>> 
> >>>>>> Can you share the wireshark trace?
> >>>>> 
> >>>>> Sure.  This covers the mount and mkdir.  The mkdir call and reply are
> >>>>> in frames 77 and 78.
> >>>> 
> >>>> Hmm.... Can you please check if the ACL is being set correctly on the server? I
> >>>> suspect that might be the source of the error.
> >>>> 
> >>> 
> >>> In fact, can you see if mounting with '-onoacl' causes the whole thing to succeed?
> >> 
> >> That's on the client mount command?  No difference.
> > 
> > By the way, I managed to do a little bisecting while working on
> > something else today, and blame landed on Chuck's
> > ba9b584c1dc37851d9c6ca6d0d2ccba55d9aad04 "SUNRPC: Introduce
> > rpc_clone_client_set_auth()".  Which makes some sense if it's an ACL
> > problem, and indeed testing on that commit finds success with -noacl,
> > failure without.
> 
> After two weeks, Bruce and I were finally able to catch up in person.
> 
> I've reproduced this on 3.7-rc5 using cthon basic tests.  The first getacl operation fails because it's mistakenly attempting to set up a fresh GSS context on a transport where one already exists.  That's in line with the kind of change that's in commit ba9b584c1.
> 
> > I'm not sure if that explains the failure I was seeing on 3.7-rc1, since
> > there I didn't see any ACL traffic, and still got a failure.  (And
> > -noacl didn't help.)
> 
> The failure occurs on the client just before the getacl request is issued, so you won't see any ACL-related network traffic in the failure case.  The failure prevents any ACL request from succeeding.
> 
> Anyway, I'll have a deeper look at this tomorrow.

Great, thanks for taking another look.

--b.
