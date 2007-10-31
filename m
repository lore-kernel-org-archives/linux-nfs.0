From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
 sign comparison
Date: Wed, 31 Oct 2007 13:41:43 -0400
Message-ID: <EXNANE014r3mbfJ8VrR0000085c@exnane01.hq.netapp.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<4728BB6E.2050104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InHZm-0002jq-24
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:41:58 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InHZq-0005B6-GG
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:42:03 -0700
In-Reply-To: <4728BB6E.2050104@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<4728BB6E.2050104@oracle.com>
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

At 01:29 PM 10/31/2007, Chuck Lever wrote:
>My proposal is to make all the variables in xdr_decode_string_inplace of 
>type u32, and then work backwards into the ULPs, changing the length 
>variables of type int to type u32.

I'd suggest a slight variation - using u32 where the variables shadow
objects which are decoded/encoded off the wire, but using a native
type (unsigned int/int) after they are actually passed outside xdr.

For example, the length here is u32 within the xdr routine, but after
the it's decoded, it's really not something we'd want to pass to
memcpy. IOW, it seems ok to me to have the "maxlen" argument
remain an int (maybe unsigned), but the internal "len" is naturally u32.

>Note however that we also have to worry about open-coded string 
>decoding, and the lengths of variable-length opaques.  I haven't even 
>looked at those yet.

Can't happen too soon, by the look of this. :-)

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
