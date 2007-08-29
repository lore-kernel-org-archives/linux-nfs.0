From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mount nfs:RPC timeout
Date: Wed, 29 Aug 2007 10:36:01 -0400
Message-ID: <1188398161.6580.68.camel@heimdal.trondhjem.org>
References: <OF75D5A8DD.ECF8A858-ON48257346.001FE1A5-48257346.00213BB5@alps.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: xiao.liang@cn.alps.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQOeS-0003Pf-7c
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 07:36:12 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQOeR-0003W5-7R
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 07:36:11 -0700
In-Reply-To: <OF75D5A8DD.ECF8A858-ON48257346.001FE1A5-48257346.00213BB5@alps.com.hk>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-08-29 at 14:08 +0800, xiao.liang@cn.alps.com wrote:
> 
> Hi, 
>    I have encounter a nfs mount problem, I use busybox1.3.1,kernel
> version 2.4.20,libc version 2.3.2. The NFS server is V4 
> 
>    The error is: 
> 
>         mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia 
>         
>    after a while 
> 
>         mount : RPC : timed out. 
>         mount: nfsmount failed: Bad file descriptor 
> 
>   I use ethereal to catch log in the NFS server side, and found the
> mount protocol is V1. And another success nfs mount use mount protocol
> V3. Is it the problem? 
>   And I do not know how can change the mount protocol to V3, I tried
> to use the same busybox, the same libc, the same kernel as the success
> mount but none worked. 
>   Any suggestion is very very very appreciate! 

mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia
            ^

Please also ensure that you have rpc.idmapd running first.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
