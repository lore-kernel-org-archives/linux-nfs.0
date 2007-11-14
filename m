From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 05/25] NFS: eliminate NIPQUAD(clp->cl_addr.sin_addr)
Date: Wed, 14 Nov 2007 11:52:49 -0500
Message-ID: <473B27E1.7020502@oracle.com>
References: <20071113183126.5087.27810.stgit@manray.1015granger.net> <20071114.104533.127429382.yoshfuji@linux-ipv6.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050607080806050807070605"
Cc: nfs@lists.sourceforge.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071114.104533.127429382.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------050607080806050807070605
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> In article <20071113183126.5087.27810.stgit@manray.1015granger.net> (at Tue, 13 Nov 2007 13:31:27 -0500), Chuck Lever <chuck.lever@oracle.com> says:
> 
>>  		   clp->rpc_ops->version,
>> -		   NIPQUAD(clp->cl_addr.sin_addr),
>> -		   ntohs(clp->cl_addr.sin_port),
>> +		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
>> +		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
>>  		   atomic_read(&clp->cl_count),
> 
> Is this really safe?

What's unsafe about it?  rpc_peeraddr2str() is designed to be called 
this way.

--------------050607080806050807070605
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQNCg0K

--------------050607080806050807070605--
