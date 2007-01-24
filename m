From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
 large
Date: Wed, 24 Jan 2007 16:28:51 -0500
Message-ID: <45B7CF93.80500@oracle.com>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124203739.GA6587@fieldses.org> <45B7C482.9090807@oracle.com>
	<20070124205134.GC6587@fieldses.org> <45B7CB0A.5040505@oracle.com>
	<20070124212501.GG6587@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070608080609080802060508"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ph3-0005tl-S7
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:30:10 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ph2-0000De-14
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:30:11 -0800
In-Reply-To: <20070124212501.GG6587@fieldses.org>
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
--------------070608080609080802060508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, Jan 24, 2007 at 04:09:30PM -0500, Chuck Lever wrote:
>> These values are just for estimating the largest size the buffers will 
>> need to be for this call and reply.  Alignment issues need to be handled 
>>  somewhere else.
> 
> OK, I'm an idiot--so cslack is just for calculating the maximum size,
> rslack is for placing the data correctly.  So now I understand what
> you're doing, and don't see any more problem with it.

Well, it might do to rename au_cslack and au_rslack so that the 
confusion isn't spread further  ;-)

--------------070608080609080802060508
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


--------------070608080609080802060508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070608080609080802060508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070608080609080802060508--
