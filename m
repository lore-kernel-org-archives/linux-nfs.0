From: Andrew Ryan <andrewr@collab.net>
Subject: Re: troubling interaction with quotas and nfs
Date: Tue, 09 Apr 2002 20:16:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CB3AE84.3A7531B7@collab.net>
References: <1018325948.2639.67.camel@milo> <15538.29176.579826.727109@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from laswell.sfo.collab.net ([64.125.134.138])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16v8WM-0006r1-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 20:11:42 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Neil Brown wrote:

>
> You could also
>    echo 32 > /proc/sys/sunrpc/nfsd_debug
> and watch for
>     "nfsd: write complete err=%d"
> messages in the kernel log.  These will tell you whether nfsd thinks
> it got an error for the write.

Can you elaborate on what the various values one could write to
/proc/sys/sunrpc/nfsd_debug and what you would get with different values in
terms of logging? This sounds like something that could be useful to many
others and included in the HOWTO or FAQ as well. I've checked the kernel docs
and they basically say to 'use the source,' but since we have some of the
core NFS client/server developers here perhaps someone can offer a few hints
for people debugging NFS configurations.

Also, is there any known or performance or stability hit to running with
NFS debug on?


thanks,
andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
