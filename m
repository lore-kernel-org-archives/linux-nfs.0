From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Problem with NFS from RedHat4 to Solaris
Date: Tue, 24 Oct 2006 15:45:25 -0400
Message-ID: <453E6D55.2090803@RedHat.com>
References: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcSDP-0008Ew-Va
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 12:45:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcSDN-0007tw-QN
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 12:45:37 -0700
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
> However, on a RedHat4 system, using the exact same mount, we
> experience odd behavior.  Through the command line, CAT'ing a file
> will show the file, but fail to return you back to the command line
> immediately.  It's as if it's waiting for the EOF characters?
> Eventually (2-5 minutes) it returns you to the command prompt.
> 
> My mount looks like
> 
> mount -t nfs  -o soft,intr,rsize=1024,wsize=1024,nosuid,udp
> mysolariserver:/opt/path /misc/path
Do it work with TCP mounts?

> 
> 
> Looking at a snoop of the traffic between the servers shows that the
> RedHat4 system seems to get hung up in a loop with about two minutes
> of this:
Is SELinux enabled?


> Any idea where I should look?
Is there anything error messages in /var/log/message?

steved.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
