Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51439 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591Ab0LHPin (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 10:38:43 -0500
Date: Wed, 8 Dec 2010 10:38:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Hills <mark@pogo.org.uk>
Cc: Chuck Lever <chuck.lever@oracle.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: mount.nfs timeout of 9999ms (was Re: Listen backlog set to 64)
Message-ID: <20101208153838.GD32305@fieldses.org>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
 <20101116182026.GA3971@fieldses.org>
 <20101117090826.4b2724da@notabene.brown>
 <20101129205935.GD9897@fieldses.org>
 <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz>
 <20101130200013.GA2108@fieldses.org>
 <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz>
 <F5FCB254-E6CE-4B71-ABD9-33F098F9E0BA@oracle.com>
 <alpine.NEB.2.01.1012071143080.28772@jrf.vwaro.pbz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.NEB.2.01.1012071143080.28772@jrf.vwaro.pbz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 08, 2010 at 02:45:40PM +0000, Mark Hills wrote:
> On Wed, 1 Dec 2010, Chuck Lever wrote:
> 
> > On Dec 1, 2010, at 1:18 PM, Mark Hills wrote:
> > 
> > > On Tue, 30 Nov 2010, J. Bruce Fields wrote:
> > > 
> > >> On Tue, Nov 30, 2010 at 05:50:52PM +0000, Mark Hills wrote:
> > > [...]
> > >>> Our investigation brings us to rpc.mountd and mount.nfs communicating. In 
> > >>> the client log we see messages like:
> > >>> 
> > >>>  Nov 24 12:09:43 nyrd001 automount[3782]: >> mount.nfs: mount to NFS server 'ss1a:/mnt/raid1/banana' failed: timed out, giving up
> > >>> 
> > >>> Using strace and isolating one of these, I can see a non-blocking connect 
> > >>> has already managed to make a connection and even send/receive some data. 
> > >>> 
> > >>> But soon a timeout of 9999 milliseconds in poll() causes a problem in 
> > >>> mount.nfs when waiting for a response of some sort. The socket in question 
> > >>> is a connection to mountd:
> > >>> 
> > >>>  26512 futex(0x7ff76affa540, FUTEX_WAKE_PRIVATE, 1) = 0
> > >>>  26512 write(3, "\200\0\0(j\212\254\365\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0\0\0\0\0\0\0\0"..., 44) = 44
> > >>>  26512 poll([{fd=3, events=POLLIN}], 1, 9999 <unfinished ...>
> > >>> 
> > >>> When it returns:
> > >>> 
> > >>>  26512 <... poll resumed> )              = 0 (Timeout)
> > >>>  26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> > >>>  26512 rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
> > >>>  26512 close(3)                          = 0
> > >>>  26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> > >>>  26512 write(2, "mount.nfs: mount to NFS server '"..., 100) = 100
> > >>> 
> > >>> There's no re-try from here, just a failed mount.
> [...]
> > >> Can you tell where the mountd threads are typically waiting?
> > > 
> > > Here's a trace from mountd. Note the long pause after fdatasync():
> > > 
> > > 31156 12:09:40 open("/var/lib/nfs/rmtab", O_WRONLY|O_CREAT|O_APPEND, 0666) = 14 <0.000010>
> > > 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
> > > 31156 12:09:40 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2af00c929000 <0.000007>
> > > 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
> > > 31156 12:09:40 lseek(14, 62642, SEEK_SET) = 62642 <0.000006>
> > > 31156 12:09:40 write(14, "192.168.14.165:/mnt/raid1/abcde_"..., 57) = 57 <0.000013>
> > > 31156 12:09:40 fdatasync(14)            = 0 <15.413401>
> [...]
> > fdatasync() will write all outstanding dirty data on that partition to 
> > persistent storage, not just the dirty data for that file.  If /var is 
> > on a partition that has a lot of other activity, then this is the 
> > expected outcome, unfortunately.  I would expect such delays to be due 
> > to a large amount of outstanding writes, not to periodic synchronous 
> > writes.
> 
> Moving rmtab to a tmpfs, this moved the problem to another bottleneck 
> writing to /var, this time via syslog.
> 
> We identified a crontab entry which uses RPM to apply updates to the 
> server OS at randomised times which was blocking /var for 10 seconds or 
> so.

So is the problem that mountd ends up waiting on a synchronous write of
one of those "authenticated mount request" log messages?

Maybe we should downgrade those messages?  On a server with a lot of
clients a log on every mount call seems obnoxious.  Doing it
synchronously even more so (though I guess that's a problem for the
syslog configuration.)

> This returns the issue to giving up after the 9999 millisecond timeout 
> above, which I think is making the client overly sensitive.
> 
> The affected clients are Fedora 12 distribution: nfs-utils-1.2.1-4.fc12. 
> We are using mount.nfs for a v3 mount over TCP.
> 
> Locating this timeout wasn't easy. There's no '9999' in any of the 
> nfs-utils or glibc's rpc code.
> 
> It turns out that the timeout originates in 
> nfs-utils/support/nfs/rpc_socket.c as
> 
>   #define NFSRPC_TIMEOUT_TCP	(10)
> 
> This is used to populate a struct timeval *timeout which is used and 
> updated by nfs_connect_nb(). Then the remaining timeout of 9999 
> milliseconds is used in an RPC clnt_call operation.
> 
> 10 seconds over TCP is simply too short to be reliable here; it's not a 
> long period of time for a fatal timeout. I will attempt to test on our 
> cluster with an extended timeout.

Should this be tied to some mount option?

Chuck probably knows how this is supposed to work....

--b.

> 
> I presume that the bug is that the timeout is too short, and not that the 
> timeout should cause a retry in a layer above -- because re-sending the 
> request over reliable TCP would not make sense.
> 
> For UDP the retries are handled inside the RPC call, clntudp_call(). In 
> which case, what is the reason the UDP timeout differs from TCP? And is it 
> also too small?
