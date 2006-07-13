From: Ian Kent <raven@themaw.net>
Subject: Re: [autofs] RE:  bug in linux mount? (says NetApp)
Date: Thu, 13 Jul 2006 21:28:57 +0800
Message-ID: <1152797337.23150.12.camel@raven.themaw.net>
References: <A0674ED473ECE741B47C065D2FB6DC2008A785@BP1XEUEX029-C.bp1.ad.bp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, gregory.baker@amd.com,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G11Fd-00059V-07
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 06:29:09 -0700
Received: from ihug-mail.icp-qv1-irony1.iinet.net.au ([203.59.1.195]
	helo=mail-ihug.icp-qv1-irony1.iinet.net.au)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G11Fa-0004rN-7X
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 06:29:09 -0700
To: "Murata, Dennis W (SAIC)" <dennis.murata@bp.com>
In-Reply-To: <A0674ED473ECE741B47C065D2FB6DC2008A785@BP1XEUEX029-C.bp1.ad.bp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-07-12 at 21:23 +0100, Murata, Dennis W (SAIC) wrote:
> I am seeing something very similar to the problem Greg has stated.  We
> are using udp rather than tcp as the transport protocol.  Should we be
> using tcp rather than udp?  That seems to be the recommendation.  I am
> testing configuration with tcp with the following arguments:
> 
> 	DAEMONOPTIONS="--timeout=60
> rsize=32768,wsize=32768,tcp,timeo=600,retrans=2,bg"

Oh .. don't background mount in autofs this will lead to problems.

> 
> We are using automount for all the nfs directories, nothing is listed in
> the /etc/fstab.  The nis maps are legacy from Solaris, and we still use
> Solaris NIS servers.  I am little reluctant to modify the maps
> themselves if I don't have to.  Will this work using the DAEMONOPTIONS
> in /etc/sysconfig/autofs?  From the mount command I see:
> 
> nfsserver:/vol/vol1/home/foo on /home/foo type nfs
> (rw,nosuid,rsize=32768,wsize=32768,tcp,timeo=600,retrans=2,bg,intr,retry
> =1000,vers=3,addr=XXX.XXX.XXX.XXX)
> 
> The entry from /proc/mounts does not list the values for timeo or
> retrans:
> 
> nfsserver:/vol/vol1/home/foo /home/foo nfs
> rw,nosuid,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=nfsserver 0
> 0
> 
> Is this normal?
> 
> Wayne Murata
> 
> -----Original Message-----
> From: nfs-bounces@lists.sourceforge.net
> [mailto:nfs-bounces@lists.sourceforge.net]On Behalf Of Trond Myklebust
> Sent: Tuesday, July 11, 2006 6:28 PM
> To: gregory.baker@amd.com
> Cc: autofs@linux.kernel.org; nfs@lists.sourceforge.net
> Subject: Re: [NFS] bug in linux mount? (says NetApp)
> 
> 
> On Tue, 2006-07-11 at 14:00 -0500, Gregory Baker wrote:
> > We have thousands of linux clients hitting netapp file servers (many 
> > 3500 series, clustered) on a local gigabit LAN.  From time to time, 
> > applications return "file not found" when attempting to automount a 
> > directory and access a file.  An example of this is a long running 
> > process, which reads in data, processes it for hours (in which time
> the 
> > filesystem is unmounted) then tries to read more data from that mount 
> > point (which causes a "file not found" error in the application).
> This 
> > occurs about 1/100th of the time.
> > 
> > Researching at Netapp turns up this bit by Chuck Lever (Linux NFS 
> > contributer)
> > 
> > "Using the Linux NFS Client with Network Appliance Filers"
> > http://www.netapp.com/libr ary/tr/3183.pdf  (February 2006)
> > 
> > page 10 says...
> > 
> > "Due to a bug in the mount command, the default retransmission timeout
> 
> > value on Linux for NFS over TCP is quite small...To obtain standard 
> > behavior, we strongly recommend using "timeo=600, retrans=2"
> explicitly 
> > when mounting via TCP."
> > 
> > Our defaults (assuming man pages are correct, RedHat Enterprise Linux
> 3) 
> > would be timeo=7, retrans=3, which translates to 7+14+28+56 = 105
> tenths 
> > of a second (10 seconds).  It appears netapp is suggesting waiting 
> > 600+600 = 1200 tenths (120 seconds) before giving up on the mount
> command...
> 
> No they are not. See below.
> 
> > * What "bug" in the mount command do you believe NetApp is talking
> about?
> 
> It has nothing to do with the mount timeout: Chuck is talking about the
> retransmission timeout for TCP connections 'timeo' which should indeed
> be set to a high value since TCP guarantees message delivery (unlike UDP
> which requires a small timeo value). Setting it too low means that you
> end up spamming your server with a load of unnecessary retransmissions.
> 
> This was indeed the case for some older versions of 'mount' and also for
> older versions of the am-utils/amd automounters.
> 
> > * What do you think proper options for NFS auto/mounts would be for 
> > extremely busy centralized NFS filers?
> 
> Something like
> 
> mount -t nfs -ohard,timeo=600,retrans=2,rsize=32768,wsize=32768,tcp
> foo:/ /bar
> 
> should be a fairly safe bet. You might want to add the 'intr' flag too,
> depending on how you feel about the behaviour w.r.t. pressing ^C.
> 
> > * What is the reference standard behavior?
> 
> To which reference are you referring?
> 
> Cheers,
>   Trond
> 
> 
> 
> ------------------------------------------------------------------------
> -
> Using Tomcat but need to do more? Need to support web services,
> security?
> Get stuff done quickly with pre-integrated technology to make your job
> easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache
> Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> _______________________________________________
> autofs mailing list
> autofs@linux.kernel.org
> http://linux.kernel.org/mailman/listinfo/autofs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
