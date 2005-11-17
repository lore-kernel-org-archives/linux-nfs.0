From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Rpc timeout error
Date: Thu, 17 Nov 2005 15:39:56 -0800
Message-ID: <1132270797.23464.581.camel@seki.nac.uci.edu>
References: <419C564F.4040508@sancharnet.in>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfsmailinglist <nfs@lists.sourceforge.net>,
	strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EctMN-0008CW-Qu
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 15:40:07 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EctML-0007E7-MU
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 15:40:07 -0800
To: Walter Faleiro <curtorkar@sancharnet.in>
In-Reply-To: <419C564F.4040508@sancharnet.in>
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

On Thu, 2004-11-18 at 02:59 -0500, Walter Faleiro wrote:
> Hi,
> I am having a linux 7.2 system serving as a nfs server. I can mount the 
> shares normally on other clients except one, which is Fedora Core 4. I 
> get this error when I try to mount the nfs share,
> Mount:RPC:Timed out.
>
> Is there any setting on FC4 that prevents nfs mounts?

iptables?

> --Walter
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
> Register for a JBoss Training Course.  Free Certification Exam
> for All Training Attendees Through End of 2005. For more info visit:
> http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
