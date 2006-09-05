From: Steve Dickson <SteveD@redhat.com>
Subject: Re: draft RPC tapset
Date: Tue, 05 Sep 2006 07:51:42 -0400
Message-ID: <44FD64CE.8080606@RedHat.com>
References: <44FD393F.8080202@cn.ltcfwd.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, systemtap@sources.redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKZTL-00056r-VH
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 04:52:08 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GKZTQ-0006JM-Sj
	for nfs@lists.sourceforge.net; Tue, 05 Sep 2006 04:52:13 -0700
To: "Gui,Jian" <guij@cn.ibm.com>
In-Reply-To: <44FD393F.8080202@cn.ltcfwd.linux.ibm.com>
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

Gui,Jian wrote:
> Hi folks,
> 
> I am working on RPC trace hooks for Systemtap/LKET. These trace
> hooks can help dynamically trace the activities on both RPC
> clients and servers.
> 
> The functions in the sunrpc module (see net/sunrpc/sunrpc_syms.c
> and others) are roughly categorized into several groups:
> * for RPC scheduler
> * for RPC client
> * for RPC client transport
> * for RPC client credential cache
> * for RPC server
> * for RPC statistics
> * for RPC caching
> * for generic XDR
> 
> As a start point, I picked the trace hooks mainly from RPC client,
> scheduler and server side. I am sure it is not always enough, so
> anyone can extend this tapset whenever necessary.
> 
> And I want to make sure the trace hooks I chose are in right places
> and the parameters are correctly handled. It will be very appreciated
> if you can take a look at it. Please fell free to let me know if
> you have any questions/suggestions/comments.
This looks very good... although until we start using the probs
we will not see how useful they are... but is a very good
start.. imho...

Question, should these probs be broken up into separate files?
and if so, where do they need to live so they will be defined
by the stap command?

steved.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
