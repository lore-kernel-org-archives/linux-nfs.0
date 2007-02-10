From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] sunrpc: remove dead variable 'rpciod_running'
Date: Fri, 09 Feb 2007 16:03:21 -0800
Message-ID: <45CD0BC9.2030208@oracle.com>
References: <20070209200649.GA9686@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070609060502000308090302"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFfil-0000Jx-CS
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 16:04:12 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFfil-00057W-QW
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 16:04:05 -0800
In-Reply-To: <20070209200649.GA9686@infradead.org>
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

This is a multi-part message in MIME format.
--------------070609060502000308090302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

At a glance, this looks reasonable.

Christoph Hellwig wrote:
> rpciod_running is not used at all, but due to the way DECLARE_MUTEX_LOCKED
> works we don't get a warning for it.
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/net/sunrpc/sched.c
> ===================================================================
> --- linux-2.6.orig/net/sunrpc/sched.c	2007-02-06 15:55:43.000000000 +0100
> +++ linux-2.6/net/sunrpc/sched.c	2007-02-06 15:55:45.000000000 +0100
> @@ -973,8 +973,6 @@
>  	spin_unlock(&rpc_sched_lock);
>  }
>  
> -static DECLARE_MUTEX_LOCKED(rpciod_running);
> -
>  static void rpciod_killall(void)
>  {
>  	unsigned long flags;


--------------070609060502000308090302
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070609060502000308090302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------070609060502000308090302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070609060502000308090302--
