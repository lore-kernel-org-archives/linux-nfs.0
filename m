From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: troubling interaction with quotas and nfs
Date: Tue, 9 Apr 2002 14:45:44 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15538.29176.579826.727109@notabene.cse.unsw.edu.au>
References: <1018325948.2639.67.camel@milo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16unSx-0002aI-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 21:42:47 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <skvidal@phy.duke.edu>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 9 Apr 2002 14:42:32 +1000
To: seth vidal <skvidal@phy.duke.edu>
In-Reply-To: message from seth vidal on  April 9
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

On  April 9, skvidal@phy.duke.edu wrote:
> Hi all,
>  I'm running red hat 7.2 with the 2.4.9-31 kernel.
> Its an ext3 file system, exported for nfsv3 udp and nfsv2 clients.
> 
> nothing fancy at all.
> 
> I have quotas set for my users. If a user hits their hard quota and the
> process continues to attempt to write to a file in their  quota'd space
> - the process load on the server shoots through the roof. 
> 
> I can reliably recreate this by setting a hard quota, having the system
> hit the hard quota and continue to attempt to write to that file - the
> server becomes terribly unhappy.
> 
> I never saw this problem on older 2.2.X servers and I'm not sure why I'm
> seeing it now.
> 
> Any places I should be looking first?
> 

tcpdump?
The server should return nfserr_dquot (69 == 0x45) and the client
should return this to the application.
But it sounds like the client is repeating the request for some
reason.

You could also 
   echo 32 > /proc/sys/sunrpc/nfsd_debug
and watch for
    "nfsd: write complete err=%d"
messages in the kernel log.  These will tell you whether nfsd thinks
it got an error for the write.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
