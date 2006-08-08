From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1 of 2] cpumask: use EXPORT_SYMBOL_GPL for new
	exports
Date: Mon, 7 Aug 2006 20:48:22 -0700
Message-ID: <20060807204822.91c4094d.pj@sgi.com>
References: <1155007534.29877.215.camel@hole.melbourne.sgi.com>
	<20060807203914.6aec29df.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	zwane@arm.linux.org.uk, gnb@melbourne.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIaA-0000al-6i
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:48:42 -0700
Received: from omx1-ext.sgi.com ([192.48.179.11] helo=omx1.americas.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIa8-0005F1-Fv
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:48:42 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060807203914.6aec29df.akpm@osdl.org>
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

> All the existing exports in lib/cpumask.c are EXPORT_SYMBOL() so I'd be
> inclined to make any new exports match that.
> 
> OK?

ok here too

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
