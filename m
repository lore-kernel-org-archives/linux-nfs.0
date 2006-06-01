From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Problems with fh_fsid_type=3 exports (device minor id >
	255)
Date: Thu, 01 Jun 2006 08:23:44 -0700
Message-ID: <1149175424.12795.57.camel@dyn9047022153>
References: <1148669319.12795.44.camel@dyn9047022153>
	 <1149115719.12795.49.camel@dyn9047022153>
	 <1149117333.12795.53.camel@dyn9047022153>
	 <17534.24605.250498.8288@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FloyT-0000N5-JV
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:20:37 -0700
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FloyL-0005F0-54
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 08:20:34 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k51FKJwT025471
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 11:20:19 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k51FKI2R260716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 09:20:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k51FKIcn006745
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 09:20:18 -0600
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17534.24605.250498.8288@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2006-06-01 at 13:33 +1000, Neil Brown wrote:
> On Wednesday May 31, ffilzlnx@us.ibm.com wrote:
> > 
> > Oops, I'm horribly confused... The above code actually is right, well
> 
> :-)  I'm glad you got your problem sorted!
> 
> > mostly, I think it actually should be:
> > 
> > > 		major = (dev & 0xff00) >> 8;
> > > 		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
> > 
> 
> No, major is 12 bits, minor is 20 bits. So the original code is
> correct.

With a bit more sleep, I see that now. Thanks.

What version of nfs-utils did this show up in? It looks like the
situation is just a mis-match of nfs-utils and kernel.

Thanks

Frank Filz




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
