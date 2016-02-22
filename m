Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-06.prod.phx3.secureserver.net ([68.178.252.107]:56943
	"EHLO p3plsmtpa11-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145AbcBVSxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 13:53:39 -0500
Subject: Re: [PATCH] nfsd: use correct byte order on rdma port.
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>
References: <1456164550-6369-1-git-send-email-steved@redhat.com>
 <34C24F04-CBFE-4226-8D7E-F4F526F1C661@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <56CB5786.9070508@talpey.com>
Date: Mon, 22 Feb 2016 10:46:30 -0800
MIME-Version: 1.0
In-Reply-To: <34C24F04-CBFE-4226-8D7E-F4F526F1C661@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/22/2016 10:33 AM, Chuck Lever wrote:
>
>> On Feb 22, 2016, at 1:09 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>> The returned port from getservbyname() is in
>> network order. Convert the port to host order
>> before writing it to the portlist file.
>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>
> /etc/services has:
>
> nfsrdma    20049/tcp
> nfsrdma    20049/udp
> nfsrdma    20049/sctp
>
> which RFC 5666 defines, but I couldn't find in the
> IANA protocols registry.

They're there:

http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.txt

nfsrdma            20049       tcp    Network File System (NFS) 
 
                                                               [RFC5666]
                                       over RDMA
nfsrdma            20049       udp    Network File System (NFS) 
 
                                                               [RFC5666]
                                       over RDMA
nfsrdma            20049      sctp    Network File System (NFS) 
 
                                                               [RFC5666]
                                       over RDMA


>
>   struct servent *sv = getservbyname("nfsrdma", "tcp");
>
> Is weird.
>
>
>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> utils/nfsd/nfssvc.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
>> index e8efd06..dcb430a 100644
>> --- a/utils/nfsd/nfssvc.c
>> +++ b/utils/nfsd/nfssvc.c
>> @@ -282,7 +282,7 @@ nfssvc_set_rdmaport(const char *port)
>> 	int fd;
>>
>> 	if (sv)
>> -		nport = sv->s_port;
>> +		nport = ntohs(sv->s_port);
>> 	else {
>> 		char *ep;
>> 		nport = strtol(port, &ep, 10);
>> --
>> 2.5.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
