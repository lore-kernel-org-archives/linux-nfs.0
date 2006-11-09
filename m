From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/12] RFC: internal RPC server clean-up to
	support IPv6
Date: Thu, 9 Nov 2006 15:19:27 +1100
Message-ID: <17746.44111.746104.987238@cse.unsw.edu.au>
References: <20061101180553.14581.77880.stgit@schiele.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi1Nt-0000at-Lk
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 20:19:25 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi1Nt-0002BO-Ac
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 20:19:26 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Wednesday November 1
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

On Wednesday November 1, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> I'm interested in your thoughts on the following clean-up patches to allow the
> Linux RPC server to support IPv6.  This doesn't constitute complete IPv6
> support, but these are necessary API changes that will allow passing and
> manipulating larger addresses.

Looks mostly good, just two specific points that I have addressed
separately, and one general point.

In a few cases you have made lines longer so they are > 80 columns
(some were already > 80 columns).
This upsets akpm, and we don't want to upset the poor man....

My script that helps me view patches contains:

	ptn='^+.*((	|[^	].{7}){10}|[ 	]$)'
	if grep -s "$ptn" $pfile > /dev/null
	then
	    less -p '$ptn' $pfile
	else
	    less $pfile
	fi

so that if I am adding any long lines or lines that end with white
space, they get very loudly highlighted for me.  If you could do
something similar I (and Andrew) would appreciate it.

Thanks (apologies for the weeks delay in getting to these).

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
