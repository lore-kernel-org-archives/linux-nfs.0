From: Neil Brown <neilb@suse.de>
Subject: Re: Problems with fh_fsid_type=3 exports (device minor id >
	255)
Date: Thu, 1 Jun 2006 13:33:49 +1000
Message-ID: <17534.24605.250498.8288@cse.unsw.edu.au>
References: <1148669319.12795.44.camel@dyn9047022153>
	<1149115719.12795.49.camel@dyn9047022153>
	<1149117333.12795.53.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fldwj-0001Mf-IO
	for nfs@lists.sourceforge.net; Wed, 31 May 2006 20:34:05 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fldwi-0002e1-06
	for nfs@lists.sourceforge.net; Wed, 31 May 2006 20:34:05 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: message from Frank Filz on Wednesday May 31
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

On Wednesday May 31, ffilzlnx@us.ibm.com wrote:
> 
> Oops, I'm horribly confused... The above code actually is right, well

:-)  I'm glad you got your problem sorted!

> mostly, I think it actually should be:
> 
> > 		major = (dev & 0xff00) >> 8;
> > 		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
> 

No, major is 12 bits, minor is 20 bits. So the original code is
correct.

NeilBrown


> The bug I'm chasing is because the install is using nfs-utils 1.0.6
> which does not handle type 3 file handles at all.
> 
> Frank
> 
> 
> 
> 
> -------------------------------------------------------
> All the advantages of Linux Managed Hosting--Without the Cost and Risk!
> Fully trained technicians. The highest number of Red Hat certifications in
> the hosting industry. Fanatical Support. Click to learn more
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
