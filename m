From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/14] SUNRPC: RPC buffer size estimates are too
 large
Date: Thu, 18 Jan 2007 19:08:40 -0500
Message-ID: <45B00C08.30502@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233052.23310.25010.stgit@localhost.localdomain>
	<20070118234956.GC14242@fieldses.org> <45B008C8.6080601@oracle.com>
	<20070119000052.GD14242@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070301090505090606040301"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hKj-0007ic-6N
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:10:17 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hKf-0006DJ-I9
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:10:14 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20070119000052.GD14242@fieldses.org>
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
--------------070301090505090606040301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> The problem is that integrity protection also adds another 8 bytes
> (length and sequence number) to the body of each rpc, and privacy in
> addition adds some variable amount of mechanism-specific encryption
> overhead (a few tens of bytes for krb5, I think).

tk_auth->au_cslack should account for this, right?  It should provide 
the largest number of bytes that could be required for the send and 
receive buffers.

> But if you're always allowing 400 bytes for the verifier then in
> practice we're not going to have any problems with the current
> mechanisms.

In practice, yes.  I would prefer we get this as right as possible now, 
so we don't get bitten by it when someone invents a GSS flavor that 
needs huge verifiers.

--------------070301090505090606040301
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


--------------070301090505090606040301
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070301090505090606040301
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070301090505090606040301--
