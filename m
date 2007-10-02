From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 11/35] svc: Add xpo_accept transport function
Date: Tue, 2 Oct 2007 13:07:56 -0400
Message-ID: <325D6316-382E-45F5-BBB8-4BE40A637C53@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192753.3250.94322.stgit@dell3.ogc.int>
	<EECEF6FF-4C84-4764-BF0B-383AA870AFDD@oracle.com>
	<1191343305.1565.24.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IclEV-0000Nx-BQ
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 10:08:33 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IclEY-0001vL-65
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 10:08:36 -0700
In-Reply-To: <1191343305.1565.24.camel@trinity.ogc.int>
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

On Oct 2, 2007, at 12:41 PM, Tom Tucker wrote:
> On Tue, 2007-10-02 at 11:33 -0400, Chuck Lever wrote:
>> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
>
> [...snip...]
>
>>> +		if (newxpt)
>>> +			svc_check_conn_limits(svsk->sk_server);
>>> +		svc_sock_received(svsk);
>>>  	} else {
>>>  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
>>>  			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
>>
>> Instead of adding a test_bit() and conditional branch here, why not
>> always call xpo_accept?  For UDP, the method simply returns.
>>
>
> That's what I thought at first too, but UDP needs to call receive  
> here.
> Doing nothing stalls the service and lockd never gets set up.

The purpose of a transport switch is to force all the transport  
specific processing down into the transport implementation so you  
don't need these SK_ switches to decide whether or not to call a  
function based on which transport is in use.

Could you instead create, say, an ->xpo_accept_and_receive hook that  
did the right thing for all three transports?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
