From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] CONFIG_NFSD_TCP actually impacts clients
Date: Sat, 1 Jul 2006 15:56:15 +1000
Message-ID: <17574.3711.649582.365653@cse.unsw.edu.au>
References: <200606291522.46235.cablnx@us.ibm.com>
	<76bd70e30606300538h6351dbffrdefe694dc99d12c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FwYT0-0000FY-Bh
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 22:56:31 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FwYSz-0000WS-AJ
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 22:56:30 -0700
To: "Chuck Lever" <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Friday June 30
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

On Friday June 30, chucklever@gmail.com wrote:
> Hi Chris-
> 
> On 6/29/06, Chris Abbey <cablnx@us.ibm.com> wrote:
> > -config NFSD_TCP
> > -       bool "Provide NFS server over TCP support"
> > -       depends on NFSD
> > +config NFS_TCP
> > +       bool "Provide NFS services over TCP"
> 
> There's been plenty of user confusion in the past about server versus
> client TCP support, so I would prefer more precise wording here.  This
> new summary almost implies that the NFS client (not the lock manager)
> is affected too.  How about something more specific like:
> 
> "Provide NFS and NLM server over TCP support"
> 
> Also, the name of the config option might be confusing as well...
> "NFS_" is usually reserved for client-only.  I suggest NFSD_NLM_TCP.

Another option would be to throw the option away altogether and
default to always listen on TCP.  We have patches that are about
  ---->  <------
this far away from being sent to the next -mm which will make protocol
selectable by rpc.nfsd.
They don't affect what protocol lockd listens on, but that is a little
awkward to manage because lockd does work for both the client and the
server....

Maybe 'lockd_up' should take some sort of protocol flag and it should
make sure the appropriate protocol was being used??

NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
