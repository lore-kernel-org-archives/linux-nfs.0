From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 11/35] svc: Add xpo_accept transport function
Date: Tue, 2 Oct 2007 14:49:47 -0400
Message-ID: <4E0C7EFB-4F52-4D65-A013-3BB66CE69845@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192753.3250.94322.stgit@dell3.ogc.int>
	<EECEF6FF-4C84-4764-BF0B-383AA870AFDD@oracle.com>
	<1191343305.1565.24.camel@trinity.ogc.int>
	<325D6316-382E-45F5-BBB8-4BE40A637C53@oracle.com>
	<1191349734.1565.52.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Icmoo-0002iv-W0
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:50:07 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Icmor-00034d-Ch
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:50:12 -0700
In-Reply-To: <1191349734.1565.52.camel@trinity.ogc.int>
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


On Oct 2, 2007, at 2:28 PM, Tom Tucker wrote:

> On Tue, 2007-10-02 at 13:07 -0400, Chuck Lever wrote:
>> On Oct 2, 2007, at 12:41 PM, Tom Tucker wrote:
>>> On Tue, 2007-10-02 at 11:33 -0400, Chuck Lever wrote:
>>>> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
>>>
>>> [...snip...]
>>>
>>>>> +		if (newxpt)
>>>>> +			svc_check_conn_limits(svsk->sk_server);
>>>>> +		svc_sock_received(svsk);
>>>>>  	} else {
>>>>>  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
>>>>>  			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
>>>>
>>>> Instead of adding a test_bit() and conditional branch here, why not
>>>> always call xpo_accept?  For UDP, the method simply returns.
>>>>
>>>
>>> That's what I thought at first too, but UDP needs to call receive
>>> here.
>>> Doing nothing stalls the service and lockd never gets set up.
>>
>> The purpose of a transport switch is to force all the transport
>> specific processing down into the transport implementation so you
>> don't need these SK_ switches to decide whether or not to call a
>> function based on which transport is in use.
>
> I don't think it's doing that. I think it's checking the "role" of the
> instance; passive vs. active endpoint. The role is transport  
> independent
> and is checked in the generic svc_recv function.
>
>>
>> Could you instead create, say, an ->xpo_accept_and_receive hook that
>> did the right thing for all three transports?
>
> You could, but IMO doing so just neuters the meaning of the
> XPT_LISTENING bit for peer-to-peer transports.

Yes, that's the point.  You wouldn't need XPT_LISTENING at all.  The  
transports would decide whether the endpoint is for listening or  
receiving internally.

So I guess what I'm asking is: "Is there a good reason to expose the  
difference between listening and receiving transport endpoints in the  
generic code?"

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
