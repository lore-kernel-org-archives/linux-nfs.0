From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: bug in linux mount? (says NetApp)
Date: Tue, 11 Jul 2006 16:21:01 -0400
Message-ID: <76bd70e30607111321m2d35fe5etc3475ac65efa9f0@mail.gmail.com>
References: <44B3F547.9010507@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0OjD-0003JM-25
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:21:07 -0700
Received: from ug-out-1314.google.com ([66.249.92.169])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0OjC-0007H2-1E
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:21:07 -0700
Received: by ug-out-1314.google.com with SMTP id m2so94800ugc
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 13:21:02 -0700 (PDT)
To: gregory.baker@amd.com
In-Reply-To: <44B3F547.9010507@amd.com>
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

On 7/11/06, Gregory Baker <gregory.baker@amd.com> wrote:
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

It's important to distinguish two different types of timeouts.

1.  The mount operation has timed out.

2.  After the mount operation succeeds, an NFS RPC operation has timed out.

TR-3183 discusses the proper settings for 2, but you are experiencing 1.

The automounter attempts to mount one of the filer's exports, but the
mount request times out causing the mounted-on directory to be
exposed.  Your filer is heavily loaded, and the filer's mountd is
single-threaded.  The filer may also be experiencing delays when
requesting information from external servers (like DNS or NIS), in
which case the mount request is held up at the filer.

Both sides are at fault:  the Linux mount command should retry (and I
believe later releases of RHEL 3 were fixed to do this) and the filer
configuration should be reviewed to make sure there are no avoidable
delays while processing mount requests.

> * What "bug" in the mount command do you believe NetApp is talking about?

The bug is that the mount command overrides the proper default RPC
timeout value with a timeout value of 0.7 seconds.  This is *not* the
timeout for mount operations, it is the timeout for the in-kernel NFS
client to retransmit RPC requests.

> * What do you think proper options for NFS auto/mounts would be for
> extremely busy centralized NFS filers?

If you are using NFS over TCP, the proper timeout value is 60 seconds.

> * What is the reference standard behavior?

Solaris, which is the NFSv3 reference implementation, uses effectively
a 60 second timeout on TCP mounts.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
