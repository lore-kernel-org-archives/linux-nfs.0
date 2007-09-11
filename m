From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/19] NFS/SUNRPC: support transport protocol
	naming
Date: Tue, 11 Sep 2007 12:03:12 -0400
Message-ID: <46E6BC40.2090605@oracle.com>
References: <EXNANE01tacom1iaCRq000004bb@exnane01.hq.netapp.com>
	<46E5E07C.5070202@oracle.com>
	<EXNANE01PMKSUW8VcOM000004ce@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050700040907050705010100"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV8Do-0002X4-Ha
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:04:17 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IV8Do-00080F-Md
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 09:04:21 -0700
In-Reply-To: <EXNANE01PMKSUW8VcOM000004ce@exnane01.hq.netapp.com>
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
--------------050700040907050705010100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 08:25 PM 9/10/2007, Chuck Lever wrote:
>> Just a general comment.
>>
>> I don't see how this will make it easier to add NFS client support for 
>> new RPC transports.  I thought we recently decided to pass down a 
>> string, and let the transports themselves register a netid that matches it?
>>
>> For example, these changes are required to support RDMA -- you can't 
>> just ship a new RDMA SUNRPC transport module and expect it to work 
>> without this ULP change.  Likewise, if we add SCTP sometime in the 
>> future, will we want to make this same kind of modification to the NFS 
>> client before the SCTP SUNRCP transport module works correctly?
> 
> Well, the "string" discussion was in the context of the server-side
> switch,

Oops.  I thought it was about both sides.

> but you call out a good goal to add transports without touching
> the upper layers.
> 
> I think the choice of integer or string is basically arbitrary. One way or
> the other, some mapping from identifier to the actual transport is defined.
> Strings are a little more self-describing, but in the end harder to maintain
> for that very reason. That's the way my thinking came down, anyway.

I guess I see it the other way.  The user specifies a string. 
Converting it to a number means something has to keep track of the mapping.

--------------050700040907050705010100
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------050700040907050705010100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------050700040907050705010100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050700040907050705010100--
