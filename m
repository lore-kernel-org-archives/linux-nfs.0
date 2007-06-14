From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 100% repeatable NFS v3 client hang
Date: Thu, 14 Jun 2007 14:03:38 -0400
Message-ID: <1181844218.6957.32.camel@heimdal.trondhjem.org>
References: <20070614165550.GB1454@danse.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: John McCorquodale <mcq@cacr.caltech.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hytfb-0000Cy-6M
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:03:43 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/q/m22pfsmtS0TjplKgJPkVty9Rj3grtU=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hytfc-0003ql-Ia
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 11:03:46 -0700
In-Reply-To: <20070614165550.GB1454@danse.us>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-06-14 at 09:55 -0700, John McCorquodale wrote:
> Guys,
> 
> I've been having a reliable problem with NFS v3 since 2.6.19 (possibly earlier;
> I didn't test), and just confirmed still present in 2.6.21.5 (x86_64).  The
> problem is that issuing the command:
> 
>   $ dd if=/dev/zero of=biggy bs=1G count=50
> 
> 100% reliably results in a hung client and completely idle server after a
> few (different each time, usually betwene 5 and 10) GB have been written.
> No output via dmesg at all.  Sometimes, however, when not writing large files,
> I'll see an occasional dmesg "NFS: desynchronized value of nfs_i.ncommit."
> It proceeds at about 30MB/s until the client eats it, and then it never wakes
> up again.  The roof fs is mounted via nfs v3, so once it eats it I can't log
> on or anything.  Serial console outputs no information during/after the eat-it
> condition, so it's not a panic.  Pings continue.  Feels deadlocky.
> 
> I saw an old dicussion/patch about something that sounded like my problem
> (but the old kernel+patch didn't fix my problem) here:
>   http://lkml.org/lkml/2007/4/21/112
> 
> This problem has been reliable and present for months for me, and I assumed
> that it was so obvious that anybody would see it immediately, and thus
> concluded that 'nobody was working on v3 anymore'.  Enough eyebrows were
> raised by that comment by my most on the v4 list this morning:
>   http://linux-nfs.org/pipermail/nfsv4/2007-June/006183.html
> that I am forced to re-evaluate that conclusion -- it appears likely that
> this may be something unique to my hardware.
> 
> The only thing at all weird about my platform is that the servers (not the
> clients) are nvidia forcedeth gigE, which has never inspired my confidence.
> The forcedeth in 2.6.21 seems fine, 'tho, as it regularly sends >800GB via
> nc for backups without hiccup or incident.
> 
> Anyway, last bit of data is that I just switched to nfs4 and the problem is
> gone.  I have successfully dd'd four 50G files-of-zeros simultaneously with
> no ill effects.
> 
> Anyway, I have a shadow server/client that I could conceivably bring v3 up on
> and run tests with if you guys would like to use me as a debugging agent or
> would like something to log in to.
> 
> I was going to ignore this, but when Trond's eyebrows went up on the v4 list,
> I figured I ought to get off my duff and report it.

The write() code had to go through emergency surgery in the 2.6.20
timeframe, since the VM/MM code was becoming increasingly intolerant of
our aging asynchronous write design. This didn't affect just NFSv3, it
affected NFSv2 and v4 too since it was in generic code.

2.6.21 still had some problems, but 2.6.22-rcX has fixes for all
reported bugs and should be stable. At least I haven't heard of any
further issues.

If you can reproduce the hang, and send me the output from an 'echo t
>/proc/sysrq-trigger', then I'd be happy to look at the resulting dump.
Don't forget to specify a large buffer size when you use dmesg: I tend
to use 'dmesg -s 90000'.
It would also be nice if you could try to reproduce the problem on a
2.6.22-rc4 kernel, to see if it is still there.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
