From: James Pearson <james-p@moving-picture.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Wed, 02 Apr 2003 12:56:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E8ACFEC.360E46FB@moving-picture.com>
References: <Pine.LNX.4.44.0304021313460.13935-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190grj-0005xb-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Apr 2003 03:57:15 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Bogdan Costescu wrote:
> 
> On Tue, 1 Apr 2003, Skottie Miller wrote:
> 
> > We do the caching to compute-node local disk, via the applications when
> > we can. But two things often make that difficult:  (1) the working set
> > of the cached data is larger than the compute-note local disk,
> 
> Ah, so you define now a working set which is a subset of the whole data
> set. In this case I would say that you can't win in any situation; it's
> similar to a process that needs memory larger than RAM and has to use the
> disk - either the OS does swapping or the process itself writes parts of
> its memory to the disk, but it has to be done continuously as the process
> jumps through memory - the disk is used in any case and the performance
> is lowered... Buy larger disks :-)
> 
> > (2) we don't own all the applications.
> 
> Yes, obviously this is a problem and can only be solved if you are a big
> enough customer for the software company :-)
> 
> But there might be some other problem: if the data set that is mostly read
> only is needed on most or all clients, updating it on the server will
> generate in a very short time a storm of requests for transfers of the new
> content. If you are using some blind OS level caching, this will create a
> big load on the server or network congestion because most or all clients
> will try to get the new data. With application level caching you might do
> nice stuff like using some priority lists, using one client that already
> got the data to send it to another client, etc.
> 

I would like to have some blind OS level caching as a starting point ...
then use some higher level application to seed the cache. In this way,
the 3rd party application doesn't need to be altered and can just get
its data from the OS's cached copy ...

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
