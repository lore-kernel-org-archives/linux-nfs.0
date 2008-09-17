From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 09:03:17 -0700 (PDT)
Message-ID: <270934.3119.qm@web32606.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32606.mail.mud.yahoo.com ([68.142.207.233]:22894 "HELO
	web32606.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753731AbYIQQDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:03:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Peter Staubach <staubach@redhat.com>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> Sent: Wednesday, September 17, 2008 4:06:44 PM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> Martin Knoblauch wrote:
> > Hi,
> >
> > the following/attached patch works around a [obscure] problem when an 2.6 (not 
> sure/caring about 2.4) NFS client accesses an "offline" file on a Sun/Solaris-10 
> NFS server when the underlying filesystem is of type SAM-FS. Happens with 
> RHEL4/5 and mainline kernels. Frankly, it is not a Linux problem, but the chance 
> for a short-/mid-term solution from Sun are very slim. So, being lazy, I would 
> love to get this patch into Linux. If not, I just will have to maintain it for 
> eternity out of tree.
> >
> > The problem: SAM-FS is Suns proprietary HSM filesystem. It stores meta-data 
> and a relatively small amount of data "online" on disk and pushes old or 
> infrequently used data to "offline" media like e.g. tape. This is completely 
> transparent to the users. If the date for an "offline" file is needed, the so 
> called "stager daemon" copies it back from the offline medium. All of this works 
> great most of the time. Now, if an Linux NFS client tries to read such an 
> offline file, performance drops to "extremely slow". After lengthly 
> investigation of tcp-dumps, mount options and procedures involving black cats at 
> midnight, we found out that the readahead behaviour of the Linux NFS client 
> causes the problem. Basically it seems to issue read requests up to 15*rsize to 
> the server. In the case of the "offline" files, this behaviour causes heavy 
> competition for the inode lock between the NFSD process and the stager daemon on 
> the Solaris server.
> >
> > - The real solution: fixing SAM-FS/NFSD interaction. Sun engineering acks the 
> problem, but a solution will need time. Lots of it.
> > - The working solution: disable the client side readahead, or make it tunable. 
> The patch does that by introducing a NFS module parameter "ra_factor" which can 
> take values between 1 and 15 (default 15) and a tunable 
> "/proc/sys/fs/nfs/nfs_ra_factor" with the same range and default.
> 
> Hi.
> 
> I was curious if a design to limit or eliminate read-ahead
> activity when the server returns EJUKEBOX was considered?

 not seriously, because that would need a lot more knowledge about the internal workings of the NFS-Client than I have. The Solaris client seems to be working along that lines, but the code to modify the readahead window looks complicated. The Solaris client also seems to be a lot less agressive when doing readahead. Maximum seems to be 4x8k. As far as I see, the Linux client doesn't really care about the readahead handling at all. It just fills "server->backing_dev_info.ra_pages" and leaves the handling to the MM system.

 Then, there is no guarantee that EJUKEBOX is ever sent by the server. If the offline archive resides on disk (e.g. a cheap SATA array), delivery will start almost immediatelly and the server will not send that error. Tracked that :-( Same for already positioned tapes.

> Unless one can know that the server and client can get into
> this situation ahead of time, how would the tunable be used?
> 

 Basically one has to know that the problem exists (that is easily detected) and that the readahead factor is involved.

 My patch has of course some pitfalls. at least:

a) as implemented, the nfs_ra_factor will be used for all NFS mounts. It should/could be per filesystem, but that needs a new mount option and I did not want to touch that code due to lack of understanding (and no time to aquire said understanding). But frankly, so far we have not observed any serious performance drawbacks with ra_factor=1.
b) changing the factor needs a remount, as the NFS client only cares about it at that time.

 Not a problem in my situation of course.

Cheers
Martin

