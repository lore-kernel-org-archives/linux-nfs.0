From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: troubling interaction with quotas and nfs
Date: Fri, 12 Apr 2002 13:04:02 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15542.20130.329038.753519@notabene.cse.unsw.edu.au>
References: <1018325948.2639.67.camel@milo>
	<15538.29176.579826.727109@notabene.cse.unsw.edu.au>
	<3CB3AE84.3A7531B7@collab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vrJ6-0002q8-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 20:01:00 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <andrewr@collab.net>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Fri, 12 Apr 2002 13:00:41 +1000
To: Andrew Ryan <andrewr@collab.net>
In-Reply-To: message from Andrew Ryan on Tuesday April 9
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

On Tuesday April 9, andrewr@collab.net wrote:
> Neil Brown wrote:
> 
> >
> > You could also
> >    echo 32 > /proc/sys/sunrpc/nfsd_debug
> > and watch for
> >     "nfsd: write complete err=%d"
> > messages in the kernel log.  These will tell you whether nfsd thinks
> > it got an error for the write.
> 
> Can you elaborate on what the various values one could write to
> /proc/sys/sunrpc/nfsd_debug and what you would get with different values in
> terms of logging? This sounds like something that could be useful to many
> others and included in the HOWTO or FAQ as well. I've checked the kernel docs
> and they basically say to 'use the source,' but since we have some of the
> core NFS client/server developers here perhaps someone can offer a few hints
> for people debugging NFS configurations.

"use the source" is really the right answer :-)
If you look in the source, it is fairly easy to see what to put in
/proc/sys/sunrpc/nfsd_debug, and you can see what the results means.

If you don't look at the source, then the debugging output probably
isn't very helpful.

However:
 If you look in
    include/linux/nfsd/debug.h
 you will see:
/*
 * knfsd debug flags
 */
#define NFSDDBG_SOCK		0x0001
#define NFSDDBG_FH		0x0002
#define NFSDDBG_EXPORT		0x0004
#define NFSDDBG_SVC		0x0008
#define NFSDDBG_PROC		0x0010
#define NFSDDBG_FILEOP		0x0020
#define NFSDDBG_AUTH		0x0040
#define NFSDDBG_REPCACHE	0x0080
#define NFSDDBG_XDR		0x0100
#define NFSDDBG_LOCKD		0x0200

So if you
   echo 1 > /proc/sys/sunrpc/nfsd_debug
it will turn on "SOCK" debugging and turn the others off.
If you
   echo 1023 > /proc/sys/sunrpc/nfsd_debug
it will turn on all debugging.

Each file in fs/nfsd/*.c has something like
#define NFSDDBG_FACILITY		NFSDDBG_FILEOP

so all dprintk calls in that file will use that facility and 
will only be printed if the right number has been written to
 ..../nfsd_debug

 
> 
> Also, is there any known or performance or stability hit to running with
> NFS debug on?

It will generate lots and lots (and lots) of messages which will
definately hurt performance, just scrolling the console if nothing
else.

I only turn it on for a few seconds at a time, or when I am
generating a very small amount of carefully controlled traffic.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
