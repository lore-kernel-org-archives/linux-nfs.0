From: "Shane Presley" <shane.presley@gmail.com>
Subject: Re: Problem with NFS from RedHat4 to Solaris
Date: Tue, 24 Oct 2006 20:02:32 -0400
Message-ID: <27ae92160610241702i62e320c2pa7d13676e61c9827@mail.gmail.com>
References: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
	<453E6D55.2090803@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcWE5-0007lJ-0a
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 17:02:33 -0700
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcWE5-00018r-PM
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 17:02:34 -0700
Received: by nf-out-0910.google.com with SMTP id p46so558527nfa
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 17:02:32 -0700 (PDT)
To: "Steve Dickson" <SteveD@redhat.com>
In-Reply-To: <453E6D55.2090803@RedHat.com>
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

On 10/24/06, Steve Dickson <SteveD@redhat.com> wrote:
> Do it work with TCP mounts?
tcp NFS behaves the same.  I prefer UDP to match the RHEL3 behavior,
but I did try TCP, and had the same problem.


> Is SELinux enabled?
Nope, no SELinux or firewall.


> Is there anything error messages in /var/log/message?
Not a thing.  I tried turning on debug level SAMBA logging, but can't
find anything that jumps out at me during the error.  And of course
this happens even without SAMBA running on top.


I'm wondering if this could be NFS version related..or something to do
with the portmapper service?  I find it odd that when I do a tcpdump
from the RHEL3 box, I never see that portmapper " PORTMAP C GETPORT"
traffic.  Just all UDP NFS packets.

Thanks,
Shane

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
