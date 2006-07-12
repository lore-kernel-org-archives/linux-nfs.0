From: Ian Kent <raven@themaw.net>
Subject: Re: [autofs] Re:  bug in linux mount? (says NetApp)
Date: Wed, 12 Jul 2006 11:03:44 +0800
Message-ID: <1152673424.2930.15.camel@raven.themaw.net>
References: <44B3F547.9010507@amd.com>
	<1152660478.5681.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, gregory.baker@amd.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0V11-0003kN-NW
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 20:03:55 -0700
Received: from ihug-mail.icp-qv1-irony1.iinet.net.au ([203.59.1.195]
	helo=mail-ihug.icp-qv1-irony1.iinet.net.au)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0V10-0006yZ-JR
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 20:03:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1152660478.5681.38.camel@lade.trondhjem.org>
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

On Tue, 2006-07-11 at 19:27 -0400, Trond Myklebust wrote:
> On Tue, 2006-07-11 at 14:00 -0500, Gregory Baker wrote:
> > We have thousands of linux clients hitting netapp file servers (many 
> > 3500 series, clustered) on a local gigabit LAN.  From time to time, 
> > applications return "file not found" when attempting to automount a 
> > directory and access a file.  An example of this is a long running 
> > process, which reads in data, processes it for hours (in which time the 
> > filesystem is unmounted) then tries to read more data from that mount 
> > point (which causes a "file not found" error in the application).  This 
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
> > value on Linux for NFS over TCP is quite small...To obtain standard 
> > behavior, we strongly recommend using "timeo=600, retrans=2" explicitly 
> > when mounting via TCP."
> > 
> > Our defaults (assuming man pages are correct, RedHat Enterprise Linux 3) 
> > would be timeo=7, retrans=3, which translates to 7+14+28+56 = 105 tenths 
> > of a second (10 seconds).  It appears netapp is suggesting waiting 
> > 600+600 = 1200 tenths (120 seconds) before giving up on the mount command...
> 
> No they are not. See below.
> 
> > * What "bug" in the mount command do you believe NetApp is talking about?
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
> mount -t nfs -ohard,timeo=600,retrans=2,rsize=32768,wsize=32768,tcp foo:/ /bar

I thought that the default timeo had changed to 600 (60 secs) for TCP
mounts in later versions of mount (it should be) and that the retrans
shouldn't matter as 60 secs is the RPC major timeout. I thought the
point of this default was to prevent RPC from retransmitting as the TCP
layer would take care of it. 

Trond what am I missing.

> 
> should be a fairly safe bet. You might want to add the 'intr' flag too,
> depending on how you feel about the behaviour w.r.t. pressing ^C.
> 
> > * What is the reference standard behavior?

I don't think it's a standard in as much as it's common sense.
Certainly if the defaults are set to those that are sensible for UDP you
are much more likely to bogus failures.

Ian



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
