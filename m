From: "Brandon D. Valentine" <brandon@dvalentine.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Fri, 27 Aug 2004 18:32:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827233235.GB57703@brandon.dvalentine.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0qDc-0001uI-S0
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:33:16 -0700
Received: from mail.michaelchaney.com ([207.65.84.68] helo=daphne.michaelchaney.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0qDc-0006u2-9w
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 16:33:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093643490.5758.120.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Aug 27, 2004 at 05:51:30PM -0400, Trond Myklebust wrote:
> To be more specific, I believe the problem here is that you are using
> an NFSv2-only kernel together with a version of mountd that is
> advertising NFSv2 *and* NFSv3.

I would be very happy to find out that it was so simple, but it doesn't
appear to be.  The problem definitely appears to be on the client
system, not the server.

  [root@scylla root]# rpcinfo -u reef nfs
  program 100003 version 2 ready and waiting
  [root@scylla root]# rpcinfo -u reef nfs 3
  rpcinfo: RPC: Program/version mismatch; low version = 2, high version = 2
  program 100003 version 3 is not available

  reef:~# ps -Af | grep mountd
  root       395     1  0 Aug17 ?        00:00:00 /usr/sbin/rpc.mountd --no-nfs-version 3

> We used to have code in the kernel that retried using NFSv2 if the
> NFSv3 GETATTR call failed. I ripped that out of 2.6.x since people
> have had ample time (I'd say 4-5 years is pretty ample) to correct
> their setups.  Add the '--no???nfs???version 3' flag to your
> rpc.mountd startup script, just as the mountd manpage clearly states
> you should do, and all will be well.

I am willing to believe that this is not a kernel bug, but can you
suggest where else in the client userland I might look for the source of
this problem?  It seems that this must either be a kernel bug or a bug
in mount(8).

I am more than willing to gather any information you might need to
discover the source of the behavior I'm experiencing.  Attached is
strace(1) output for the mount(1) command.  Hopefully that'll make it
through mailman, but I'll leave you in the Cc in case it doesn't.  The
mount binary on this system is stripped, so I don't know how much more
useful debug information I can get out of it without compiling a debug
version of mount.  FWIW, the mount binary on this FC2 system comes from:

  [root@scylla root]# rpm -q --whatprovides /bin/mount
  util-linux-2.12-18

Let me know how I can help.

Thanks,

Brandon D. Valentine
-- 
brandon@dvalentine.com                           http://www.geekpunk.net
Pseudo-Random Googlism:  sunlight is the sun's weekly nonduplicating
                         shopper


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
