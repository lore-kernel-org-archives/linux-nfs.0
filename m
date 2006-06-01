From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] expkey_parse doesn't handle type 3 exports (was Re: [NFS]
 Problems with fh_fsid_type=3 exports (device minor id > 255))
Date: Thu, 01 Jun 2006 10:51:59 -0700
Message-ID: <1149184319.12795.63.camel@dyn9047022153>
References: <1148669319.12795.44.camel@dyn9047022153>
	 <1149115719.12795.49.camel@dyn9047022153>
	 <1149117333.12795.53.camel@dyn9047022153>
	 <17534.24605.250498.8288@cse.unsw.edu.au>
	 <1149175424.12795.57.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlrHb-0005gd-MA
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 10:48:31 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlrHa-0004an-DW
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 10:48:30 -0700
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FlrHZ-0007jg-7x
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 10:48:30 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k51HmM9A004191
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 13:48:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k51HmMBI234300
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 11:48:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k51HmMGv007449
	for <nfs@lists.sourceforge.net>; Thu, 1 Jun 2006 11:48:22 -0600
To: Neil Brown <neilb@suse.de>
In-Reply-To: <1149175424.12795.57.camel@dyn9047022153>
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

On Thu, 2006-06-01 at 08:23 -0700, Frank Filz wrote:
> On Thu, 2006-06-01 at 13:33 +1000, Neil Brown wrote:
> > On Wednesday May 31, ffilzlnx@us.ibm.com wrote:
> > > 
> > > Oops, I'm horribly confused... The above code actually is right, well
> > 
> > :-)  I'm glad you got your problem sorted!
> > 
> > > mostly, I think it actually should be:
> > > 
> > > > 		major = (dev & 0xff00) >> 8;
> > > > 		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
> > > 
> > 
> > No, major is 12 bits, minor is 20 bits. So the original code is
> > correct.
> 
> With a bit more sleep, I see that now. Thanks.
> 
> What version of nfs-utils did this show up in? It looks like the
> situation is just a mis-match of nfs-utils and kernel.

I tried the 1.0.8 version of rpc.mountd, and things almost worked, but
the mount still failed. I looked at expkey_parse, and discovered it
doesn't handle type 3 exports. The following patch fixes the problem:

Signed-Off-By: Frank Filz <ffilzlnx@us.ibm.com>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -132,7 +132,7 @@ static int expkey_parse(struct cache_det
 	if (*ep)
 		goto out;
 	dprintk("found fsidtype %d\n", fsidtype);
-	if (fsidtype > 2)
+	if (fsidtype > 3)
 		goto out;
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
