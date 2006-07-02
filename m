From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: query about kernel 2.4.21-37.ELsmp
Date: Sun, 02 Jul 2006 11:11:26 -0400
Message-ID: <1151853086.2656.3.camel@tleilax.poochiereds.net>
References: <20060608042448.97900.qmail@web51615.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fx3cA-00076q-Dp
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 08:12:02 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fx3c9-0002OF-6a
	for nfs@lists.sourceforge.net; Sun, 02 Jul 2006 08:12:02 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060608042448.97900.qmail@web51615.mail.yahoo.com>
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

On Wed, 2006-06-07 at 21:24 -0700, mehta kiran wrote:
> Hi,
>     From where can i get information about all the
> bugs
>     which were there in redhat kernel 2.4.21-37.ELsmp
> ?
>     I want to know if there existed a bug which
>     did not allow unmounting of device which was once
>     nfs exported and accessed by clients
> 
> Thanks,
>  kiran

2.4.21-45.EL and greater (and hence U8) should have a fix for this
problem. See:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=167636

for more info.

-- Jeff



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
