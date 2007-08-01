From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Wed, 01 Aug 2007 06:58:21 -0400
Message-ID: <46B0674D.7000803@RedHat.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>	<46A7A5F8.4040204@oracle.com>	<46A897CD.50201@RedHat.com>	<46A96032.7080503@oracle.com>	<46AA089E.50503@RedHat.com>	<1185551769.6586.28.camel@localhost>	<46AA1A70.5010705@RedHat.com>	<1185553679.6586.34.camel@localhost>	<46AA2642.60505@RedHat.com>	<1185556406.6586.45.camel@localhost>	<46AB3BE9.1060903@RedHat.com>
	<1185906627.6700.30.camel@localhost> <46AFA98E.1070904@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGBvy-0003sb-Os
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 04:00:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGBw1-0007o8-Dq
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 04:00:10 -0700
In-Reply-To: <46AFA98E.1070904@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Chuck Lever wrote:
> I was looking at this yesterday.  The stock timeout for TCP connects on 
> Linux is 75 seconds.  The version of getport() used in the mount command 
> might control the TCP connect timeout by using a non-blocking connect() 
> with a select().  The select() then times out if the connection doesn't 
> complete.
> 
> But I'm wondering if we really want to continue using TCP for GETPORT 
> calls.  Solaris mount appears to use only UDP for GETPORT, for example.
As as long as the GETPORTs don't use privilege ports I don't think its
a problem... plus I don't think one size fixes all.. meaning due to
different firewalls requirements both udp and tcp GETPORTS will be
needed... imho...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
