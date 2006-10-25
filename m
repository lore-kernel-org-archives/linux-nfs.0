From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Problem with NFS from RedHat4 to Solaris
Date: Wed, 25 Oct 2006 10:11:16 -0400
Message-ID: <453F7084.7070601@RedHat.com>
References: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcjTi-0004N5-6C
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 07:11:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcjTf-0005RD-Un
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 07:11:35 -0700
To: Shane Presley <shane.presley@gmail.com>
In-Reply-To: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
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

Shane Presley wrote:
> 
> Looking at a snoop of the traffic between the servers shows that the
> RedHat4 system seems to get hung up in a loop with about two minutes
> of this:
> 
> myredhat4server -> mysolaris9server          PORTMAP C GETPORT
> prog=100021 (NLM) vers=4 proto=UDP
>          mysolaris9server -> myredhat4server PORTMAP R GETPORT port=0
ah... port=0 means it can't get server's port number for lockd...
make sure the lockd on the server is running...

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
