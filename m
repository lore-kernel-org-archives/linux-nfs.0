From: suzuki <suzuki@in.ibm.com>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Tue, 11 Sep 2007 10:26:10 +0530
Message-ID: <46E61FEA.9010800@in.ibm.com>
References: <46E121B8.4080105@linux.vnet.ibm.com>
	<6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com>
	<1189289549.13713.4.camel@localhost.localdomain>
	<46E4FC2F.6040105@in.ibm.com>
	<1189458228.6634.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	neilb@suse.de, linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, bfields@fieldses.org,
	nfs@lists.sourceforge.net, ffilz@us.ibm.com,
	Poornima <bnpoorni@in.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUxpD-00006t-2G
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 21:58:11 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IUxpH-0002na-HQ
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 21:58:15 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8B4xUR0014473
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 00:59:30 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l8B4w5q2541448
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 00:58:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l8B4w4KX022937
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 00:58:04 -0400
In-Reply-To: <1189458228.6634.4.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
> On Mon, 2007-09-10 at 13:41 +0530, suzuki wrote:
>> Hi
>>
>> I have been trying to debug this issue from my side and could find the 
>> following.
>>
>> The pathconf() request gets a reply with :
>>
>> pathinfo.max_namelen = (unsiged int) -1
>> pathinfo.max_link    = 255
>>
>> Is this really an expected answer from a server for a proper connection 
>> ( for mount requests on an exported dir) ? Is there something that needs 
>> to be fixed at server side ?
> 
> I assume that this is with my patch applied? 

No. This is without your patch. So I am trying to debug why the server 
is sending a -1 ! (which sounds like an error ?)

Thanks

Suzuki K P
IBM Linux Technology Centre

Yes: as long as the kernel
> sets NAME_MAX to 255, then the above is expected behaviour.
> 
> Trond
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
