From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Fail to start rpc nfsd
Date: Sun, 12 Nov 2006 07:16:06 -0500
Message-ID: <1163333766.3131.7.camel@tleilax.poochiereds.net>
References: <20061112001731.49149.qmail@web35208.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjEG3-0006EH-RP
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 04:16:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GjEG4-0006P9-QB
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 04:16:21 -0800
To: Stephen Liu <satimis@yahoo.com>
In-Reply-To: <20061112001731.49149.qmail@web35208.mail.mud.yahoo.com>
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

On Sun, 2006-11-12 at 08:17 +0800, Stephen Liu wrote:
> Hi Trond,
> 
> Tks for your advice.
> 
> > > I'm following;
> > > https://help.ubuntu.com/ubuntu/serverguide/C/index.html
> > > Network File System (NFS)
> > >
> > https://help.ubuntu.com/ubuntu/serverguide/C/network-file-system.html
> > > 
> > > to build a LAMP server which is for test only, not for production.
> > > Failed to start "nfs-kernel-server"
> > > 
> > > 
> > > $ sudo /etc/init.d/nfs-kernel-server start
> > > Password:
> > >  * Exporting directories for NFS kernel daemon...
> > > [ ok ]
> > >  * Starting rpc nfsd...                              [fail]
> 
> - snip -
> 
> > > Please advise how to fix the problem.  TIA 
> > 
> > sudo /etc/init.d/portmap start
> 
> $ sudo /etc/init.d/portmap start
> Password:
> 
>  * Not starting portmap daemon.  Already running.     [ ok ]
> * end *
> 
> It said already running.
> 
> What will be this command for;
> /etc/init.d/nfs-kernel-server start
> 

Depending on the distribution, it may just be that the script left a
lockfile or something out there. Make sure it's actually running with
'ps'.

If that's not it, then it's just not responding for some reason. Check
your firewalling and make sure you're not blocking port 111. If that's
not it, then it's probably hung for some reason and you'll need to do a
bit of investigation as to why.

-- Jeff



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
