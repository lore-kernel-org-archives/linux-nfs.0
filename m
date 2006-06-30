From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH] CONFIG_NFSD_TCP actually impacts clients
Date: Fri, 30 Jun 2006 08:29:13 -0700
Message-ID: <1151681353.4538.9.camel@dyn9047022153>
References: <200606291522.46235.cablnx@us.ibm.com>
	<76bd70e30606300538h6351dbffrdefe694dc99d12c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FwKuZ-00033N-P4
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 08:28:04 -0700
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FwKuY-0002U4-2R
	for nfs@lists.sourceforge.net; Fri, 30 Jun 2006 08:28:04 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5UFRtdk026224
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Fri, 30 Jun 2006 11:27:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k5UFRKVQ297090
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 30 Jun 2006 09:27:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k5UFRtfF028839
	for <nfs@lists.sourceforge.net>; Fri, 30 Jun 2006 09:27:55 -0600
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <76bd70e30606300538h6351dbffrdefe694dc99d12c7@mail.gmail.com>
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

On Fri, 2006-06-30 at 08:38 -0400, Chuck Lever wrote:
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

The problem is that lockd also provides services to the NFS client, for
example the NLM_GRANTED rpc which goes from server to client to notify
the client of a granted blocking lock.

Frank Filz




Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
