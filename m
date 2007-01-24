From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
 large
Date: Wed, 24 Jan 2007 16:09:30 -0500
Message-ID: <45B7CB0A.5040505@oracle.com>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124203739.GA6587@fieldses.org> <45B7C482.9090807@oracle.com>
	<20070124205134.GC6587@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080104010100020808050600"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9pPI-000443-JF
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:11:48 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9pPJ-0008Ew-SD
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:11:50 -0800
In-Reply-To: <20070124205134.GC6587@fieldses.org>
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
--------------080104010100020808050600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, Jan 24, 2007 at 03:41:38PM -0500, Chuck Lever wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Jan 24, 2007 at 02:20:20PM -0500, Chuck Lever wrote:
>>>> + 	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
>>>> + 	req->rq_callsize <<= 2;
>>>> + 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
>>>> + 	req->rq_rcvsize <<= 2;
>>> What happened to rslack?  The callsize calculation should be using
>>> cslack and the rcvsize calculation rslack, I think, right?
>> As far as I understood it, cslack is the size of the authentication 
>> verifier for that flavor.  Shouldn't that be the same for calls and replies?
> 
> No--it can even vary from one call or reply to the next, and we can't
> necessarily exactly predict the size of the reply verifier (though we
> should be able to give a fairly tight upper bound).

I assume that cslack is the maximum size of any possible verifier or 
credential.  For calls, I reserve 2 * cslack bytes in the send buffer 
(to account for the credential and verifier), and for replies I reserve 
cslack bytes for the receive buffer.

> Also the call has a
> credential in addition to the verifier, and the credential size also
> depends on the security flavor.

These values are just for estimating the largest size the buffers will 
need to be for this call and reply.  Alignment issues need to be handled 
  somewhere else.

>>> In the krb5p case there's an extra annoyance: rslack is used to decide
>>> where to expect page data to start, so it can only take into account
>>> extra space needed at the beginning.  But krb5p has to add padding, for
>>> example, to the end of each request.
>> That padding has to follow XDR rules, though, correct?
> 
> This is padding at a different level--the plaintext usually has to be
> padded to the nearest block size (at least 8 bytes) before encryption.

That doesn't sound like XDR at all.  I don't see how RPC buffer 
allocation could be concerned about this...

--------------080104010100020808050600
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


--------------080104010100020808050600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080104010100020808050600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080104010100020808050600--
