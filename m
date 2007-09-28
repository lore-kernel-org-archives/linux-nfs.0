From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
 PATCH 25/33] svc: Move the sockaddr information to svc_xprt
Date: Fri, 28 Sep 2007 12:53:08 -0400
Message-ID: <46FD3174.2060605@oracle.com>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>	<20070927050227.12677.32560.stgit@dell3.ogc.int>	<18172.33988.315021.626126@notabene.brown>
	<1190997890.10604.58.camel@trinity.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050605080801030700070305"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbJ7Y-0000A3-6T
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:55:20 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbJ7c-00011P-0r
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:55:25 -0700
In-Reply-To: <1190997890.10604.58.camel@trinity.ogc.int>
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
--------------050605080801030700070305
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> On Fri, 2007-09-28 at 14:36 +1000, Neil Brown wrote:
>> On Thursday September 27, tom@opengridcomputing.com wrote:
>>> Move the IP address fields to the svc_xprt structure. Note that this 
>>> assumes that _all_ RPC transports must have IP based 4-tuples. This 
>>> seems reasonable given the tight coupling with the portmapper etc...
>>> Thoughts?
>> I don't think NFSv4 requires portmapper (or rpcbind) ... does it?
>>
>> "Everything uses IP addresses" sounds a lot like "Everything is a
>> socket".  I would have supported the latter strongly until RDMA came
>> along.  Now I'm even less sure about the former.
>>
>> How much cost would there be in leaving the address in the
>> per-transport data?
> 
> Very little. The original patchset had it in the per-transport data.

For comparison, the client keeps the remote endpoint address in the 
generic transport data, stored in a struct sockaddr_storage.

I am also trepidacious about claiming all things use IP addresses, but 
the reality is NFS itself is built assuming IP.  There would be so much 
more to change (like how export rules work) that I think we can safely 
assume that IP addresses are the format for identifying remote endpoints 
until we have clear evidence that a change it needed, imo.

--------------050605080801030700070305
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


--------------050605080801030700070305
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------050605080801030700070305
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050605080801030700070305--
