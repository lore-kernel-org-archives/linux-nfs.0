From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 11:01:01 -0500
Message-ID: <20060714110101.A27025@yoda.lmcg.wisc.edu>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
	<1152870249.28636.34.camel@devel.office.ancoso-development.de>
	<1152879442.28635.40.camel@devel.office.ancoso-development.de>
	<1152879562.28633.42.camel@devel.office.ancoso-development.de>
	<76bd70e30607140615x606fb651r61d09d636147336b@mail.gmail.com>
	<1152890024.28625.70.camel@devel.office.ancoso-development.de>
	<20060714102757.A29831@yoda.lmcg.wisc.edu>
	<1152891264.28625.77.camel@devel.office.ancoso-development.de>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1Q6F-0007su-DM
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 09:01:07 -0700
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1Q6F-0005ls-Ir
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 09:01:07 -0700
To: Stefan Palme <kleiner@hora-obscura.de>
In-Reply-To: <1152891264.28625.77.camel@devel.office.ancoso-development.de>;
	from kleiner@hora-obscura.de on Fri, Jul 14, 2006 at 05:34:24PM
	+0200
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

Stefan,

> > What I have done in similar cases is the following:
> > 
> > 1.) Remote site creates file1
> > 2.) Local site creates foo
> > 3.) Local site tries to link foo to file1 (this should fail)
> > 4.) Local site removes foo
> > 5.) Local site opens file1
> > 
> > In bash the last 4 steps are:
> > 
> > $ touch foo
> > $ ln foo file1
> > ln: `file1': File exists
> > $ rm foo
> > $ cat file1
> > 
> > Perhaps you could try something similar in Python?
> 
> Thank you for that tip, maybe I will use this as a last resort,
> if I don't find the reason for this "misbehaviour", because it 
> looks a little big "ugly" and creates a lot of overhead...

Actually there isn't much overhead, since anything you do that ensures
coherency is going to require a round trip to the NFS server.  If there
is an already existing file that you know of in the directory you can
eliminate "foo" entirely and just use:

$ ln alreadyexists file1
ln: `file1': File exists


And get the same effect.

-- 
Dan


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
