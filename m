From: Ian Kent <raven@themaw.net>
Subject: Re: NFS Server, Buffer Cache Utilization
Date: Wed, 30 Aug 2006 22:32:11 +0800
Message-ID: <20060830143200.GA20077@raven.themaw.net>
References: <32fc08be0608290854j191bbe6fn74e0fb6a721d70f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GIR7I-0002S6-Bw
	for nfs@lists.sourceforge.net; Wed, 30 Aug 2006 07:32:32 -0700
Received: from 203-59-155-146.dyn.iinet.net.au ([203.59.155.146]
	helo=raven.themaw.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GIR7H-0000gS-7W
	for nfs@lists.sourceforge.net; Wed, 30 Aug 2006 07:32:33 -0700
To: Brent Franks <brentasterisk@gmail.com>
In-Reply-To: <32fc08be0608290854j191bbe6fn74e0fb6a721d70f9@mail.gmail.com>
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

On Tue, Aug 29, 2006 at 11:54:50AM -0400, Brent Franks wrote:
> 
> Because the box has 4gigs of ram, we began digging around and found that the
> box is only currently using about 1Gig of Ram (See Below)
> 

I think you need a kernel with the PAE extension options.
They used to have "bigmem" in the name.

Ian


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
