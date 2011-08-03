Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:50714 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574Ab1HCVS3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 17:18:29 -0400
Subject: Re: [PATCH] rpc.statd: Bind downcall socket to loopback address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E398915.6070603@RedHat.com>
Date: Wed, 3 Aug 2011 17:18:15 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <15B872DE-F8F7-40DE-AB66-0B3EB141AB1C@oracle.com>
References: <20110801201129.3503.99913.stgit@seurat.1015granger.net> <4E398915.6070603@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 3, 2011, at 1:44 PM, Steve Dickson wrote:

> 
> 
> On 08/01/2011 04:13 PM, Chuck Lever wrote:
>> In the past, rpc.statd posted SM_NOTIFY requests using the same socket
>> it used for sending downcalls to the kernel.  To receive replies from
>> remote hosts, the socket was bound to INADDR_ANY.
>> 
>> With commit f113db52 "Remove notify functionality from statd in
>> favour of sm-notify" (Mar 20, 2007), the downcall socket is no longer
>> used for sending requests to remote hosts.  However, the downcall
>> socket is still bound to INADDR_ANY.
>> 
>> Thus a remote host can inject data on this socket since it is an
>> unconnected UDP socket listening for RPC replies.  Thanks to f113db52,
>> the port number of this socket is no longer controlled by a command
>> line option, making it difficult to firewall.
>> 
>> We have demonstrated that data injection on this socket can result in
>> a DoS by causing rpc.statd to consume CPU and log bandwidth, but so
>> far we have not found a breach.
>> 
>> To prevent unwanted data injection, bind this socket to the loopback
>> address.
>> 
>> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=177
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Committed..

Do you want to close out bz 177, or shall I?  Or we can wait for the next nfs-utils release (1.2.5?) to mark it FIXED.

> steved.
> 
>> ---
>> 
>> Confirmed that reboot recovery still works, and that data injection
>> is no longer possible.  This is an updated and final version of this
>> patch.
>> 
>> utils/statd/rmtcall.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
>> index 0e52fe2..4ecb03c 100644
>> --- a/utils/statd/rmtcall.c
>> +++ b/utils/statd/rmtcall.c
>> @@ -85,7 +85,7 @@ statd_get_socket(void)
>> 
>> 		memset(&sin, 0, sizeof(sin));
>> 		sin.sin_family = AF_INET;
>> -		sin.sin_addr.s_addr = INADDR_ANY;
>> +		sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
>> 
>> 		if (bindresvport(sockfd, &sin) < 0) {
>> 			xlog(D_GENERAL, "%s: can't bind to reserved port",
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



