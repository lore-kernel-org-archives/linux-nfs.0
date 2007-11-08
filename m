From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH 1/7] SUNRPC: Fix a race in xs_tcp_state_change()
Date: Thu, 08 Nov 2007 10:40:37 -0500
Message-ID: <47332DF5.6050202@oracle.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>	
	<20071107003940.13713.65472.stgit@heimdal.trondhjem.org>	
	<47323A62.9000803@oracle.com>
	<1194474763.7504.57.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050801090104030106050003"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1194474763.7504.57.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------050801090104030106050003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-11-07 at 17:21 -0500, Chuck Lever wrote:
>> Trond Myklebust wrote:
>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>
>>> When scheduling the autoclose RPC call, we want to ensure that we don't
>>> race against the test_bit() call in xprt_clear_locked().
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>
>>>  include/linux/sunrpc/xprt.h |    1 +
>>>  net/sunrpc/xprt.c           |   20 ++++++++++++++++++++
>>>  net/sunrpc/xprtsock.c       |    5 +----
>>>  3 files changed, 22 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>> index 30b17b3..6f524a9 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -246,6 +246,7 @@ struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
>>>  void			xprt_complete_rqst(struct rpc_task *task, int copied);
>>>  void			xprt_release_rqst_cong(struct rpc_task *task);
>>>  void			xprt_disconnect(struct rpc_xprt *xprt);
>>> +void			xprt_force_disconnect(struct rpc_xprt *xprt);
>>>  
>>>  /*
>>>   * Reserved bit positions in xprt->state
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index 282a9a2..48c5a8b 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -570,6 +570,7 @@ static void xprt_autoclose(struct work_struct *work)
>>>  
>>>  	xprt_disconnect(xprt);
>>>  	xprt->ops->close(xprt);
>>> +	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>> xs_close already clears the CLOSE_WAIT bit, and so does xs_tcp_shutdown 
>> (added in a later patch).  So this hunk appears to be unnecessary.
>>
>> But xprt_rdma_close doesn't clear CLOSE_WAIT, it appears.  Do we want to 
>> copy (some of) the logic from the end of xs_close into xprt_rdma_close?
> 
> Nah. I'd like to move the XPRT_CLOSE_WAIT stuff into xprt.c in order to
> convert it into a generic way of telling the transport layer that we
> want it to shut down. It is already in the xprt_clear_locked() logic, so
> this is really just a cleanup of the current hack.

That's fine.  But you still clear XPRT_CLOSE_WAIT twice in a row in 
xprt_autoclose, at least for the socket transport method.  Either clear 
it in xprt_autoclose, or clear it in the tranport close methods.  Not 
both.  It doesn't break anything, but it is confusing to human readers.

I'm still a little confused about which state flags are supposed to be 
managed entirely by the transports, and which by the generic logic.  Can 
you perhaps add a block comment in xprt.h where the flags are defined 
that describes how these flags are supposed to be used?  Actually, even 
better would be to have a separate state word for the transports, 
defined in their private transport structure.  The 
non-connection-oriented transports wouldn't need to manipulate the 
specific flags.

--------------050801090104030106050003
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
version:2.1
end:vcard


--------------050801090104030106050003
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------050801090104030106050003--
