From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 1 of 2] cpumask: use EXPORT_SYMBOL_GPL for new
	exports
Date: Tue, 08 Aug 2006 13:40:47 +1000
Message-ID: <1155008446.29877.219.camel@hole.melbourne.sgi.com>
References: <1155007534.29877.215.camel@hole.melbourne.sgi.com>
	<20060807203914.6aec29df.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Jackson <pj@sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAISl-0008SU-9e
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:41:03 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAISl-0004pP-Jl
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:41:03 -0700
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

On Tue, 2006-08-08 at 13:39, Andrew Morton wrote:
> All the existing exports in lib/cpumask.c are EXPORT_SYMBOL() so I'd be
> inclined to make any new exports match that.
> 
> <edits the diffs>
> 
> OK?

Fine by me.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
