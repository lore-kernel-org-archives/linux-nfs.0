From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Mon, 6 Nov 2006 18:08:49 -0500
Message-ID: <4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
References: <20061031001248.GA19915@uio.no>
	<4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
	<20061031100346.GA2906@uio.no>
	<4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
	<20061031143248.GA8444@uio.no> <20061103123737.GA5199@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhDaK-00086O-At
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:08:56 -0800
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GhDaH-0004Dg-7d
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:08:56 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1151934ugc
	for <nfs@lists.sourceforge.net>; Mon, 06 Nov 2006 15:08:49 -0800 (PST)
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20061103123737.GA5199@uio.no>
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

On 11/3/06, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> On Tue, Oct 31, 2006 at 03:32:48PM +0100, Steinar H. Gunderson wrote:
> > Data is no longer available on those existing mounts. In fact, if I run ls
> > -ld on the mount point, it is suddenly owned by the user and group "?".
>
> I figured out later that this isn't always true -- for instance, in one case
> root could ls a directory, but others couldn't (and new mounts wouldn't
> work).
>
> >> Could you send a packet trace from the server after mounts stop
> >> working?  (tcpdump -s 0 -w /tmp/x)  Also, if it is enabled, could you
> >> get the output from sysRq-T?
> > I'll be sure to grab the data next time the problems occur.
>
> Here we go. The dump is a complete tcpdump from the server (129.241.93.19) at
> the same time as a client (129.241.93.50) attempts to do a "mount -t nfs4 -o
> sec=krb5i cassarossa:/itk /mnt". The call traces is the result of a "cat
> /proc/kmsg" while running "echo t > /proc/sysrq-trigger".

Hello Steinar,
The userland messages from svcgssd all indicate it is happy and is
sending down a context to the kernel.  The packet trace shows that the
kernel is replying to the NULL call with GSS_S_NO_CONTEXT.  This can
be returned by the kernel if it is unable to find the context that was
(supposedly) sent down from svcgssd.

It is a mystery to me why this is happening.  Especially mysterious is
that restarting svcgssd clears it up.  Can you check to see if there
are memory or other resource problems with svcgssd when it stops
working?

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
