From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mountd segfault on itanium2
Date: Fri, 30 Apr 2004 20:15:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040501001535.GA23498@fieldses.org>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJiAQ-0004jL-2o
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 17:15:42 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJiAP-0003aN-OJ
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 17:15:41 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20040430234327.GM22498@polop.usc.edu>
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

On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples wrote:
> I just spotted a pattern.  After collecting several strace samples, it always
> segfaults after read() or write() to fd 5.  And fd 5 is always:
> 
>    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) = 5

Any interesting messages from the kernel (in /var/log/messages)?

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
