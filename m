From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: max memory size on input queue?
Date: 04 Jun 2003 12:12:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1054746729.4430.11.camel@mosix>
References: <3EDE192D.4000602@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NboC-0006cS-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Jun 2003 10:12:21 -0700
To: Tom Georgoulias <tom.georgoulias@motorola.com>
In-Reply-To: <3EDE192D.4000602@motorola.com>
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

On Wed, 2003-06-04 at 11:07, Tom Georgoulias wrote:
> Is there any agreement on what is the safest, largest input queue memory 
> size?  /etc/syconfig/nfs has an option to turn this value to 256k, so it 
> that generally the best setting to use?  What about 512k?
> 
> Tom

I am not an expert on input queues, but from my experience, the 256K
recommendation is based on 8 threads.. the goal is to give 32K to each
thread, so if you have 16 threads, you would want 512K. I do not know if
there is a good way to find out if more on top of 32K would be good..
32K/thread (my servers run 64threads) works well for me so far with 1
Gigabit and two 100Mbit interfaces on each server.


> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
> thread debugger on the planet. Designed with thread debugging features
> you've never dreamed of, try TotalView 6 free at www.etnus.com.
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
Matt Schillinger
mschilli@vss.fsi.com





-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
