From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
 large
Date: Wed, 24 Jan 2007 15:50:37 -0500
Message-ID: <45B7C69D.1090709@oracle.com>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124204724.GB6587@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050603060504010702070306"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9p5n-00027K-RJ
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:51:40 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9p5g-0005tZ-1B
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:51:35 -0800
In-Reply-To: <20070124204724.GB6587@fieldses.org>
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
--------------050603060504010702070306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, Jan 24, 2007 at 02:20:20PM -0500, Chuck Lever wrote:
>> The RPC buffer size estimation logic in net/sunrpc/clnt.c always
>> significantly overestimates the requirements for the buffer size.
>> A little instrumentation demonstrated that in fact rpc_malloc was never
>> allocating the buffer from the mempool, but almost always called kmalloc.
>>
>> To compute the size of the RPC buffer more precisely, split p_bufsiz into
>> two fields; one for the argument size, and one for the result size.
>>
>> So now we will compute the sum of the exact call and reply header sizes,
>> and split the RPC buffer precisely between the two.  That should keep
>> almost all RPC buffers within the 2KiB buffer mempool limit.
> 
> One other worry: after this patch, as I understand it, a small mistake
> in any of the definitions of the *_sz macros could allow a buffer
> overflow that RPC_SLACK_SPACE previously prevented.
> 
> Those definitions are all handwritten, and I'd be suprised if there
> aren't at least a few minor errors.
> 
> I'd certainly rather have these calculations be exact than depend on
> this big RPC_SLACK_SPACE fudge factor, but is there some way we could
> verify those macros first?

I've been running Connectathon and fsx-odirect with hundreds of 
thousands of ops on a kernel that has all the slab debugging options 
enabled.  I haven't hit a problem yet.

And besides, the RPC buffers are all a fixed size (2kiB), and much 
larger than required already.  The slack is "built in" to the buffer size.

--------------050603060504010702070306
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


--------------050603060504010702070306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------050603060504010702070306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050603060504010702070306--
