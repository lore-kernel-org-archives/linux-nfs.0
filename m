From: Ian Kent <raven@themaw.net>
Subject: Re: [NFS] Attempting to mount a large number of directories
Date: Mon, 07 Jan 2008 17:45:04 +0900
Message-ID: <1199695504.3156.69.camel@raven.themaw.net>
References: <200712241200.08410.lists@fabis-site.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Fabian Steiner <lists-A1xC5SIKT5unwkN7LPkuEg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59939 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908AbYAGJJw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2008 04:09:52 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JBnzO-00050A-94
	for linux-nfs@vger.kernel.org; Mon, 07 Jan 2008 20:09:46 +1100
In-Reply-To: <200712241200.08410.lists-A1xC5SIKT5unwkN7LPkuEg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-24 at 12:00 +0100, Fabian Steiner wrote:
> Hello!
> 
> After having finished the migration to our new setup (user home directories 
> are mounted automatically using autofs [4.1.4-8ubuntu1] and NFSv3) we are 
> experiencing some problems which use to occur whenever many users attempt to 
> access their directories. If such an issue appears the following messages 
> will be seen in /var/log/syslog of the server:
> 
> Dec 23 18:38:00 ubuntu1 mountd[8995]: refused mount request from client 
> for /exports/dir157 (/exports): illegal port 59537
> 
> At first we thought it would be an autofs problem but after having tried to 
> reproduce the problem employing normal nfs mounts we encountered the same 
> issues. The attached scripts might help you to reproduce it.
> 
> Running these scripts reveal that mounting 105 directories work, the 106th 
> fails, however, resulting in the following error: 
> 
> [...]
> Working on dir 105 ...nfs bindresvport: Address already in use
> OK
> Working on dir 106 ...mount: 192.168.0.46:/exports/dir106: can't read 
> superblock
> OK
> [...]
> 
> At next, I added the "insecure" option to my /etc/exports file and increased 
> the value of /proc/sys/sunrpc/max_resvport from 1023 to 5000. Now 139 
> directories can be mounted without any single error, then "nfs bindresvport: 
> Address already in use" appears again and mounting 141-172 also works fine. 
> Afterwards all the other mount attempts are failing.
> 
> Could you explain this behaviour? What does "nfs bindresvport: Address already 
> in use" try to tell me? Generally speaking both the server as well as the 
> client should run out of open ports.

I see no-one else wanted to buy into this.
I'm not really surprised.

Judging by your attempt to use the insecure option I assume you actually
know that you're running out of port space on the client. The server, of
course, consumes only a few ports, like ports for mountd, portmap (or
rpcbind) and NFS and because it's a server and it reuses the same port
since the different port used on the client makes the tupple
clientaddr,clientport,serveraddr,serverport unique. Point is that port
space is consumed on the client not the server.

So running out of port space is a client problem and the reason it
happens is that autofs and mount probe to see if the server is up and
what version of NFS is available etc. before doing the mount. This can
result in as many a 9 ports consumed for each mount and the ports that
aren't continuing to be used can't be reused before a timeout has
passed. I think it's about 60 seconds, and is required for the TCP
implementation to function properly. So you run out of available ports
fairly quickly if you issue many mount requests at once.

Quite a bit of work has been done to reduce the port usage over time and
I think it has been included in recent nfs-utils releases so perhaps a
later nfs-utils will help.

Really, the main problem here is that socket pooling for RPC would be
really hard to do in user space, if it can be done at all.

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

