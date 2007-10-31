From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
 sign comparison
Date: Wed, 31 Oct 2007 15:14:52 -0400
Message-ID: <EXNANE01NtqMk7LiHdl00000861@exnane01.hq.netapp.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<1193857219.7454.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InJ1y-0003zI-QA
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 12:15:11 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InJ22-0002iU-Tk
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 12:15:16 -0700
In-Reply-To: <1193857219.7454.70.camel@heimdal.trondhjem.org>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<1193857219.7454.70.camel@heimdal.trondhjem.org>
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

At 03:00 PM 10/31/2007, Trond Myklebust wrote:
>
>On Wed, 2007-10-31 at 13:06 -0400, Talpey, Thomas wrote:
>> This is a serious vunerability! A huge string length will always be
>> accepted by this code, right? Security/integrity bug, not a minor
>> sign cleanup IOW.
>
>Wrong! The current code is quite correct.
>
>It trusts that the caller is setting a reasonable value for maxlen, and
>assumes that 'len' is the untrusted value (since it comes from the
>network).

Hmm - okay right you are, the unsigned is wider and therefore maxlen
is promoted. So the current code is safe, pfew.

>
>in the comparison
>
>  ((len = ntohl(*p++)) < maxlen)
>
>then the trusted value maxlen is the one that gets cast to an unsigned
>value since 'len' and 'maxlen' are both integers of the same rank (see
>the description of the usual binary conversions in section 6.3.4 in
>Harbison and Steele).
>
>Chuck's patch _introduces_ the bug, since it causes the above comparison
>to become a signed comparison. In that case, you also need to test for
>len<0.

Actually, shouldn't it be len <= 0 ? ;-) If len == 0 then there isn't any
data to point to inline since XDR doesn't marshal zero bytes.

Tom.

>
>Trond
>
>> Tom.
>> 
>> At 12:50 PM 10/31/2007, Chuck Lever wrote:
>> >xdr_decode_string_inplace() compares an incoming length to a maximum length
>> >allowed by the protocol.  Make sure both sides of the comparison have the
>> >same sign.
>> >
>> >A better fix for this would be always to use unsigned 32-bit integers for
>> >string lengths.  To wit, RFC 4506 says:
>> >
>> >4.2.  Unsigned Integer
>> >
>> >   An XDR unsigned integer is a 32-bit datum that encodes a non-negative
>> >   integer in the range [0,4294967295].
>> >
>> > ...
>> >
>> >4.11.  String
>> >
>> >   The standard defines a string of n (numbered 0 through n-1) ASCII
>> >   bytes to be the number n encoded as an unsigned integer (as described
>> >   above), and followed by the n bytes of the string.
>> >
>> >This would mean fixing up the callers of xdr_decode_string_inplace, which
>> >include the NFS server's filename handling functions (including
>> >decode_filename, decode_pathname, and nfsd_lookup), and lockd's nlm_lock
>> >structure.
>> >
>> >Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> >---
>> >
>> > net/sunrpc/xdr.c |    2 +-
>> > 1 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> >diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> >index 3d1f7cd..db80a77 100644
>> >--- a/net/sunrpc/xdr.c
>> >+++ b/net/sunrpc/xdr.c
>> >@@ -95,7 +95,7 @@ xdr_encode_string(__be32 *p, const char *string)
>> > __be32 *
>> > xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
>> > {
>> >-	unsigned int	len;
>> >+	int len;
>> > 
>> > 	if ((len = ntohl(*p++)) > maxlen)
>> > 		return NULL;
>> >
>> >
>> >-------------------------------------------------------------------------
>> >This SF.net email is sponsored by: Splunk Inc.
>> >Still grepping through log files to find problems?  Stop.
>> >Now Search log events and configuration files using AJAX and a browser.
>> >Download your FREE copy of Splunk now >> http://get.splunk.com/
>> >_______________________________________________
>> >NFS maillist  -  NFS@lists.sourceforge.net
>> >https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
