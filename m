From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 13/35] svc: Change services to use new svc_create_xprt service
Date: Wed, 3 Oct 2007 11:25:50 -0400
Message-ID: <D376113E-3F59-4E3D-BE3D-AE778647BD0E@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192758.3250.2651.stgit@dell3.ogc.int>
	<608B3480-525A-43C6-945C-3482CDE823FC@oracle.com>
	<1191343505.1565.28.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id6me-0003Lq-Fs
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 09:09:12 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id6mj-0001dW-Bx
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 09:09:17 -0700
In-Reply-To: <1191343505.1565.28.camel@trinity.ogc.int>
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

On Oct 2, 2007, at 12:45 PM, Tom Tucker wrote:
> On Tue, 2007-10-02 at 11:44 -0400, Chuck Lever wrote:
>> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
>>>
>>> Modify the various kernel RPC svcs to use the svc_create_xprt  
>>> service.
>>>
>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>> ---
>>>
>>>  fs/lockd/svc.c                 |   17 ++++++++---------
>>>  fs/nfs/callback.c              |    4 ++--
>>>  fs/nfsd/nfssvc.c               |    4 ++--
>>>  include/linux/sunrpc/svcsock.h |    1 -
>>>  net/sunrpc/sunrpc_syms.c       |    1 -
>>>  net/sunrpc/svcsock.c           |   22 ----------------------
>>>  6 files changed, 12 insertions(+), 37 deletions(-)
>>>
>>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>>> index 82e2192..8686915 100644
>>> --- a/fs/lockd/svc.c
>>> +++ b/fs/lockd/svc.c
>>> @@ -219,13 +219,12 @@ lockd(struct svc_rqst *rqstp)
>>>  	module_put_and_exit(0);
>>>  }
>>>
>>> -
>>> -static int find_socket(struct svc_serv *serv, int proto)
>>> +static int find_xprt(struct svc_serv *serv, char *proto)
>>>  {
>>>  	struct svc_sock *svsk;
>>>  	int found = 0;
>>>  	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
>>> -		if (svsk->sk_sk->sk_protocol == proto) {
>>> +		if (strcmp(svsk->sk_xprt.xpt_class->xcl_name, proto) == 0) {
>>>  			found = 1;
>>>  			break;
>>>  		}
>>
>> This is scary.  :-)
>>
>
> Yes, I agree. In fact, this is the "last place" where svcs ramble  
> around
> svc_xprt internals. This was along the lines of "how much bigger do I
> make this patchset". BTW, this function was already here , I just
> modified it.
>
>> First, I think we would be better off making the server transport API
>> stronger by not allowing ULPs to dig around in svc_xprt or the
>> svc_xprt_class structures directly.  Perhaps you could provide a
>> method for obtaining the transport's NETID.
>
> I'll propose a service. NETID or simply protocol/port? What's the
> consensus?

I think NETID is all that is needed here.

You might consider moving the whole function into the RPC server to  
make this even cleaner.  The fact that this facility is planted  
squarely in lockd is a bit of a layering violation to begin with.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
