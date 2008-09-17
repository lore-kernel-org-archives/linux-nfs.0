From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 10:01:32 -0700 (PDT)
Message-ID: <2236.70458.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32607.mail.mud.yahoo.com ([68.142.207.234]:38715 "HELO
	web32607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757989AbYIQRBd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 13:01:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Chuck Lever <chucklever@gmail.com>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: Peter Staubach <staubach@redhat.com>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> Sent: Wednesday, September 17, 2008 6:43:48 PM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> On Wed, Sep 17, 2008 at 11:23 AM, Martin Knoblauch wrote:
> > ----- Original Message ----
> >
> >> From: Chuck Lever 
> >> To: Peter Staubach 
> >> Cc: Martin Knoblauch ; linux-nfs list 
> ; linux-kernel@vger.kernel.org
> >> Sent: Wednesday, September 17, 2008 5:41:15 PM
> >> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> >>
> >> On Wed, Sep 17, 2008 at 9:06 AM, Peter Staubach wrote:
> >> > Martin Knoblauch wrote:
> >> >>
> >> >> Hi,
> >> >>
> >> >> the following/attached patch works around a [obscure] problem when an 2.6
> >> >> (not sure/caring about 2.4) NFS client accesses an "offline" file on a
> >> >> Sun/Solaris-10 NFS server when the underlying filesystem is of type 
> SAM-FS.
> >> >> Happens with RHEL4/5 and mainline kernels. Frankly, it is not a Linux
> >> >> problem, but the chance for a short-/mid-term solution from Sun are very
> >> >> slim. So, being lazy, I would love to get this patch into Linux. If not, I
> >> >> just will have to maintain it for eternity out of tree.
> >> >>
> >> >> The problem: SAM-FS is Suns proprietary HSM filesystem. It stores
> >> >> meta-data and a relatively small amount of data "online" on disk and 
> pushes
> >> >> old or infrequently used data to "offline" media like e.g. tape. This is
> >> >> completely transparent to the users. If the date for an "offline" file is
> >> >> needed, the so called "stager daemon" copies it back from the offline
> >> >> medium. All of this works great most of the time. Now, if an Linux NFS
> >> >> client tries to read such an offline file, performance drops to "extremely
> >> >> slow". After lengthly investigation of tcp-dumps, mount options and
> >> >> procedures involving black cats at midnight, we found out that the 
> readahead
> >> >> behaviour of the Linux NFS client causes the problem. Basically it seems 
> to
> >> >> issue read requests up to 15*rsize to the server. In the case of the
> >> >> "offline" files, this behaviour causes heavy competition for the inode 
> lock
> >> >> between the NFSD process and the stager daemon on the Solaris server.
> >> >>
> >> >> - The real solution: fixing SAM-FS/NFSD interaction. Sun engineering acks
> >> >> the problem, but a solution will need time. Lots of it.
> >> >> - The working solution: disable the client side readahead, or make it
> >> >> tunable. The patch does that by introducing a NFS module parameter
> >> >> "ra_factor" which can take values between 1 and 15 (default 15) and a
> >> >> tunable "/proc/sys/fs/nfs/nfs_ra_factor" with the same range and default.
> >> >
> >> > Hi.
> >> >
> >> > I was curious if a design to limit or eliminate read-ahead
> >> > activity when the server returns EJUKEBOX was considered?
> >> > Unless one can know that the server and client can get into
> >> > this situation ahead of time, how would the tunable be used?
> >>
> >> I tend to agree.  A tunable is probably not a good solution in this case.
> >>
> >> I would bet that this lock contention issue is a problem in other more
> >> common cases, and would merit some careful analysis.
> >>
> >
> >  Are you talking wrt. a Solaris NFS-Server with SAM-FS/QFS as backend 
> filesystem?
> 
> I misread your mail, and thought the inode lock contention issue was
> on the client.
> 

 No problem, maybe I was not articulating myself clearly.  Just to restate - the lock contention happens on the server.

Cheers
Martin

