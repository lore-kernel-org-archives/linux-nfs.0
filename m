From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: more SMP issues
Date: Wed, 27 Mar 2002 13:59:51 +1100 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15521.13735.293466.799706@notabene.cse.unsw.edu.au>
References: <200203261934.NAA25602@popmail.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16q3d3-0006PI-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 18:57:37 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <habanero@us.ibm.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 27 Mar 2002 13:57:25 +1100
To: Andrew Theurer <habanero@us.ibm.com>
In-Reply-To: message from Andrew Theurer on Tuesday March 26
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

On Tuesday March 26, habanero@us.ibm.com wrote:
> Again, with udp I cannot get nfsd_busy to exceed 1.  TCP has the same 
> behavior as the last test.  My first thought was that maybe the way the bits  
> are set and cleared for the socket (SK_BUSY, SK_DATA, SK_CONN, etc) could be 
> causing a problem here, but I cannot confirm that.  It appears they behave 
> the same way for tcp and udp, so that is probably not it.  So, I am now stuck 
> here.  If there is anyone interested in helping me investigate this (Neil?), 
> please let me know. Thanks for your help.
> 

Its very odd.

I'm doing some testing on 2.4.18 plus my patches, using UDP, and I'm
definately getting more than 12 threads being used at times.  But this
is a mixed load, not a read-only load.

Could you

 echo 256 > /proc/sys/sunrpc/rpc_debug ; sleep 5 ; echo 0 >  /proc/sys/sunrpc/rpc_debug 

while the udp reading is happening and see if lines mentioning
   "no space"
appear in the log.  That is about the only thing that I can think of.

The fact that you seem to get more threads if you only ask for 2 is
really odd....

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
