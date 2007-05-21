From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
 PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Mon, 21 May 2007 10:29:46 -0400
Message-ID: <4651ACDA.7050207@oracle.com>
References: <20070521031940.GF7482@sgi.com>	<C2767CB3.30B42%tom@opengridcomputing.com>	<20070521041617.GG7482@sgi.com>
	<18001.8854.771127.95716@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090003020205060401020902"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqA7D-0005ps-P4
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:48:07 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqA7F-0001cu-Fx
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:48:10 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1Hq8uF-0006L5-Gb
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 07:30:41 -0700
In-Reply-To: <18001.8854.771127.95716@notabene.brown>
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

This is a multi-part message in MIME format.
--------------090003020205060401020902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Monday May 21, gnb@sgi.com wrote:
>> In any case I'm happy to do whatever is necessary in the transport
>> patchset,  but I'd appreciate Neil's guidance on which approach he'd
>> prefer before I go in with the scalpel.  Neil?
> 
> I cannot immediately see the value in having different debug bits for
> the socket transport code and the RDMA transport code.  The key
> question is "When would you want to see the debugging from one, but
> not from the other", and I cannot see when that would be.  Almost
> certainly if you are testing one transport, you will not be using the
> other, so it will not contribute any noise.

That's how I did it in the client transport switch.  One bit enables 
debug messages for all transports.

> So I suspect we should simply
> #define RPCDBG_FACILITY	RPCDBG_SVCSOCK

That's expedient, but I suggest you rename the flag to something less 
specific to sockets.

> in any server-RDMA specific files, and see how we go.

--------------090003020205060401020902
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------090003020205060401020902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090003020205060401020902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090003020205060401020902--
