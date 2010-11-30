Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.ij.cx ([212.13.201.15]:53748 "EHLO wes.ijneb.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751167Ab0K3WJN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 17:09:13 -0500
Date: Tue, 30 Nov 2010 22:09:09 +0000 (GMT)
From: Mark Hills <mark@pogo.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: Listen backlog set to 64
In-Reply-To: <20101130200013.GA2108@fieldses.org>
Message-ID: <alpine.LNX.2.01.1011302145300.16684@fgnk.ybpnyqbznva>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz> <20101116182026.GA3971@fieldses.org> <20101117090826.4b2724da@notabene.brown> <20101129205935.GD9897@fieldses.org> <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz>
 <20101130200013.GA2108@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 30 Nov 2010, J. Bruce Fields wrote:

> On Tue, Nov 30, 2010 at 05:50:52PM +0000, Mark Hills wrote:
> > On Mon, 29 Nov 2010, J. Bruce Fields wrote:
> > 
> > > On Wed, Nov 17, 2010 at 09:08:26AM +1100, Neil Brown wrote:
> > > > On Tue, 16 Nov 2010 13:20:26 -0500
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Mon, Nov 15, 2010 at 06:43:52PM +0000, Mark Hills wrote:
> > > > > > I am looking into an issue of hanging clients to a set of NFS servers, on 
> > > > > > a large HPC cluster.
> > > > > > 
> > > > > > My investigation took me to the RPC code, svc_create_socket().
> > > > > > 
> > > > > > 	if (protocol == IPPROTO_TCP) {
> > > > > > 		if ((error = kernel_listen(sock, 64)) < 0)
> > > > > > 			goto bummer;
> > > > > > 	}
[...]
> > I think we can hold off changing the queue size, for now at least. We 
> > reduced the reported queue overflows by increasing the number of mountd 
> > threads, allowing it to service the queue more quickly.
> 
> Apologies, I should have thought to suggest that at the start.

No apology necessary. I actually thought we had ruled out the possibility 
that mountd is at fault, but I cannot remember the exact reasons. I think 
it is because we have _some_ cases of failure on a mounted filesystem. So 
maybe we will find ourselves back here again later.

> > However this did not fix the common problem, and I was hoping to have 
> > more information in this follow-up email.
> > 
> > Our investigation brings us to rpc.mountd and mount.nfs communicating. In 
> > the client log we see messages like:
> > 
> >   Nov 24 12:09:43 nyrd001 automount[3782]: >> mount.nfs: mount to NFS server 'ss1a:/mnt/raid1/banana' failed: timed out, giving up
> > 
> > Using strace and isolating one of these, I can see a non-blocking connect 
> > has already managed to make a connection and even send/receive some data. 
> > 
> > But soon a timeout of 9999 milliseconds in poll() causes a problem in 
> > mount.nfs when waiting for a response of some sort. The socket in question 
> > is a connection to mountd:
> > 
> >   26512 futex(0x7ff76affa540, FUTEX_WAKE_PRIVATE, 1) = 0
> >   26512 write(3, "\200\0\0(j\212\254\365\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0\0\0\0\0\0\0\0"..., 44) = 44
> >   26512 poll([{fd=3, events=POLLIN}], 1, 9999 <unfinished ...>
> > 
> > When it returns:
> > 
> >   26512 <... poll resumed> )              = 0 (Timeout)
> >   26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> >   26512 rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
> >   26512 close(3)                          = 0
> >   26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> >   26512 write(2, "mount.nfs: mount to NFS server '"..., 100) = 100
> > 
> > There's no re-try from here, just a failed mount.
> 
> That does sound wrong.  I'm not at all familiar with automount,
> unfortunately; how is it invoking mount.nfs?

It invokes 'mount' as a command using exec(). A more detailed log:

  Nov 22 12:07:36 nyrf014 automount[7883]: mount_mount: mount(nfs): calling mount -t nfs -s -o proto=tcp ss1a:/mnt/raid1/banana /proj/banana
  Nov 22 12:07:48 nyrf014 automount[7883]: >> mount.nfs: mount to NFS server 'ss1a:/mnt/raid1/banana' failed: timed out, giving up

The process trying to access the filesystem will block whilst automount 
does this. The failure of the mount command causes an empty directory 
until negative timeout expires, after which it will invoke 'mount' again. 
It's this period that causes problems; applications fail when they see an 
empty directory.

It looks like we are more likely to _see_ the problem when a large number 
of hosts are mounting at the same time, but it doesn't seem to be directly 
the cause of it.
 
> > What is the source of this 9999 millisecond timeout used by poll() in 
> > mount.nfs? It was not clear in an initial search of nfs-utils and glibc, 
> > but I need more time to investigate.
> > 
> > If the server is being too slow to respond, what could the cause of this 
> > be? Multiple threads are already in use, but it seems like they are not 
> > all in use because a thread is able to accept() the connection. I haven't 
> > been able to pin this on the forward/reverse DNS lookup used by 
> > authentication and logging.
> 
> Can you tell where the mountd threads are typically waiting?

I intend to investigate this, possibly by attaching strace to rpc.mountd 
and trying to correlate the log with one of the dropouts. Perhaps somebody 
has a better suggestion.

-- 
Mark
