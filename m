From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 12/35] svc: Add a generic transport svc_create_xprt function
Date: Thu, 4 Oct 2007 11:18:48 -0400
Message-ID: <B16CBD55-C114-43D1-A2D2-8C0D7EB28032@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192756.3250.60536.stgit@dell3.ogc.int>
	<383DDDA6-29E5-41CF-A2F7-9C45BB26CE64@oracle.com>
	<20071004023024.GU21388@sgi.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdSTp-0000Fs-9k
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 08:19:13 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdSTp-0005Cn-6x
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 08:19:17 -0700
In-Reply-To: <20071004023024.GU21388@sgi.com>
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

On Oct 3, 2007, at 10:30 PM, Greg Banks wrote:
> On Tue, Oct 02, 2007 at 11:39:18AM -0400, Chuck Lever wrote:
>> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
>>>
>>> struct svc_xprt_ops {
>>> +	struct svc_xprt	*(*xpo_create)(struct svc_serv *,
>>> +				       struct sockaddr *,
>>> +				       int);
>>
>> Should xpo_create also have a length argument, as in (struct sockaddr
>> *, socklen_t) ?
>
> Consistency would be nice.  Let's see, how often do we
> maintain address length fields now?
>
> svc_deferred_req.addr: yes
> svc_rqst.rq_addr: yes
> svc_sock.sk_local: no
> svc_sock.sk_remote: yes
> rpc_xprt.addr: yes
> rpc_create_args.address:     \
> rpc_create_args.saddress:    / one length field for both
> rpc_xprtsock_create.srcaddr: \
> rpc_xprtsock_create.dstaddr: / one length field for both
> rpc_peeraddr(): yes
> rpcb_create(): no
> xs_send_kvec(): yes
> xs_sendpages(): yes
> __svc_print_addr(): no
> svc_port_is_privileged(): no
> svc_create_socket(): yes
>
>> (or whatever the type of sockaddr lengths are: size_t perhaps?)
>
> socklen_t should be right, but the kernel doesn't seem to have one.

FYI I've been using size_t as I convert "struct sockaddr_in *" to  
"struct sockaddr *, length".

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
