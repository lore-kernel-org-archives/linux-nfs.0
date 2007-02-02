From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in
 NFS server.
Date: Fri, 02 Feb 2007 11:15:58 -0500
Message-ID: <45C363BE.50205@oracle.com>
References: <20070202153531.18622.patches@notabene> <adahcu55fiu.fsf@cisco.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030008010605070805070602"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HD164-0001Zx-EU
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 08:17:08 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HD162-0001Wz-3e
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 08:17:10 -0800
In-Reply-To: <adahcu55fiu.fsf@cisco.com>
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
--------------030008010605070805070602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Roland Dreier wrote:
>  > They are mostly from Chuck Level and make preparating for IPv6 support
>  > in the NFS server.
>  > They are *not* for 2.6.20, but should be ok for .21.
> 
> Out of curiousity, does this patch series reduce the delta between the
> NFS/RDMA tree and mainline Linux?  In other words does this bring
> NFS/RDMA closer to merging?

Hi Roland-

The client side support for an RPC/RDMA module is almost completely 
integrated into mainline.  There is still a minimal set of patches 
required to support alternate transports in loadable kernel modules 
which Trond has indicated he will integrate when the RPC/RDMA transport 
is ready to be integrated.

At this time I'm not aware of a plan to integrate server-side support 
for NFS/RDMA.  Perhaps the NetApp RDMA developers could respond.

--------------030008010605070805070602
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
title:Principle Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------030008010605070805070602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------030008010605070805070602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030008010605070805070602--
