From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] bug in linux mount? (says NetApp)
Date: Tue, 11 Jul 2006 19:27:58 -0400
Message-ID: <1152660478.5681.38.camel@lade.trondhjem.org>
References: <44B3F547.9010507@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: gregory.baker@amd.com
In-Reply-To: <44B3F547.9010507@amd.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://hera.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-07-11 at 14:00 -0500, Gregory Baker wrote:
> We have thousands of linux clients hitting netapp file servers (many 
> 3500 series, clustered) on a local gigabit LAN.  From time to time, 
> applications return "file not found" when attempting to automount a 
> directory and access a file.  An example of this is a long running 
> process, which reads in data, processes it for hours (in which time the 
> filesystem is unmounted) then tries to read more data from that mount 
> point (which causes a "file not found" error in the application).  This 
> occurs about 1/100th of the time.
> 
> Researching at Netapp turns up this bit by Chuck Lever (Linux NFS 
> contributer)
> 
> "Using the Linux NFS Client with Network Appliance Filers"
> http://www.netapp.com/libr ary/tr/3183.pdf  (February 2006)
> 
> page 10 says...
> 
> "Due to a bug in the mount command, the default retransmission timeout 
> value on Linux for NFS over TCP is quite small...To obtain standard 
> behavior, we strongly recommend using "timeo=600, retrans=2" explicitly 
> when mounting via TCP."
> 
> Our defaults (assuming man pages are correct, RedHat Enterprise Linux 3) 
> would be timeo=7, retrans=3, which translates to 7+14+28+56 = 105 tenths 
> of a second (10 seconds).  It appears netapp is suggesting waiting 
> 600+600 = 1200 tenths (120 seconds) before giving up on the mount command...

No they are not. See below.

> * What "bug" in the mount command do you believe NetApp is talking about?

It has nothing to do with the mount timeout: Chuck is talking about the
retransmission timeout for TCP connections 'timeo' which should indeed
be set to a high value since TCP guarantees message delivery (unlike UDP
which requires a small timeo value). Setting it too low means that you
end up spamming your server with a load of unnecessary retransmissions.

This was indeed the case for some older versions of 'mount' and also for
older versions of the am-utils/amd automounters.

> * What do you think proper options for NFS auto/mounts would be for 
> extremely busy centralized NFS filers?

Something like

mount -t nfs -ohard,timeo=600,retrans=2,rsize=32768,wsize=32768,tcp foo:/ /bar

should be a fairly safe bet. You might want to add the 'intr' flag too,
depending on how you feel about the behaviour w.r.t. pressing ^C.

> * What is the reference standard behavior?

To which reference are you referring?

Cheers,
  Trond
