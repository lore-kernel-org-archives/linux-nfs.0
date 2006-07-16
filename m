From: Neil Brown <neilb@suse.de>
Subject: Re: nfs problems with 2.6.18-rc1
Date: Mon, 17 Jul 2006 09:23:38 +1000
Message-ID: <17594.51834.20365.820166@cse.unsw.edu.au>
References: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2FyD-0004Df-RE
	for nfs@lists.sourceforge.net; Sun, 16 Jul 2006 16:24:17 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G2FyC-0004lw-Rb
	for nfs@lists.sourceforge.net; Sun, 16 Jul 2006 16:24:18 -0700
To: Janos Farkas <chexum+dev@gmail.com>
In-Reply-To: message from Janos Farkas on Thursday July 13
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

On Thursday July 13, chexum+dev@gmail.com wrote:
> Hi!
> 
> I recently updated two (old) hosts to 2.6.18-rc1, and started noticing
> weird things with the nfs mounted /home s.

So this is both the client and the server that you upgraded?  That
makes is harder to point the finger of blame :-)

> 
> I frequently face EACCESs where a few minutes ago there wasn't any
> problem, and after a retry everything does work again.
> 

I wonder if that is pointing the finger at

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8c7b389e532e964f07057dac8a56c43465544759

as that is a recent change that returns 'EACCES'... but I cannot see
that being relevant in this case as it only affects directories.

> 
> How can I help with tracing this?  git bisecting on these machines takes
> at least an hour per step, (and no reasonable connectivity either to
> compile elsewhere much quicker).

The standard answer for tracing nfs problems if 'tcpdump'.
e.g. 
  tcpdump -s 0 -w /tmp/trace host $CLIENT and host $SERVER and port 2049

that should show whether the error is coming from the server, or if
the client is generating it all by itself.
If you can get a reasonably small '/tmp/trace', compress it and attach
it to an email.

Also turn on tracing. Something like:
on server
   echo 32767 > /proc/sys/sunrpc/nfsd_debug
on client
   echo 32767 > /proc/sys/sunrpc/nfs_debug

You can be a bit more selective by only enabling individual flags.
For the server, these are in include/linux/nfsd/debug.h
You probably want FH, EXPORT AUTH PROC FILEOP

For the client, they are near the end of include/linux/nfs_fs.h
Not sure which to choose... maybe just all of them.

NeilBrown


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
