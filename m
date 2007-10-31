From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
 sign comparison
Date: Wed, 31 Oct 2007 14:06:09 -0400
Message-ID: <EXNANE01MXb0zrAXBir0000085d@exnane01.hq.netapp.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<4728BB6E.2050104@oracle.com>
	<EXNANE014r3mbfJ8VrR0000085c@exnane01.hq.netapp.com>
	<4728C1E1.7060006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InHxe-0005Rd-Ns
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 11:06:39 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InHxj-0006sF-8N
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 11:06:44 -0700
In-Reply-To: <4728C1E1.7060006@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<4728BB6E.2050104@oracle.com>
	<EXNANE014r3mbfJ8VrR0000085c@exnane01.hq.netapp.com>
	<4728C1E1.7060006@oracle.com>
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

At 01:56 PM 10/31/2007, Chuck Lever wrote:
>However, it seems to me that native string lengths should be size_t. 
>(ie the same type that strlen() returns).

Sounds right (if a tad huge for xdr purposes).

If anyone ever builds a machine without a native 32-bit type, I'm sure
a lot of this code will need fixing. :-) As it is, the xdr_hyper support is
the only truly portable integer marshaling w.r.t. non-native object sizing.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
