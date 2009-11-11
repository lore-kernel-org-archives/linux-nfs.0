From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Wed, 11 Nov 2009 10:53:39 -0500
Message-ID: <2031D0B0-56C9-406E-B5CF-EE050E2CB437@oracle.com>
References: <bug-14546-10286@http.bugzilla.kernel.org/> <20091110152908.7558a471.akpm@linux-foundation.org> <967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Linux Network Developers <netdev@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Fabio Olive Leite <fabio.olive@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39867 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757389AbZKKP4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 10:56:53 -0500
In-Reply-To: <967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2009-11-11 Fabio Olive Leite wrote:
> On 2009-11-11 Patroklos Argyroudis wrote:
>> There is no need to increase the size of the buffer since the new
>> check (if (uaddr_len > sizeof(buf) - 2)) will terminate the function
>> in case the valid universal address is RPCBIND_MAXUADDRLEN bytes.
> On a second note, why is '\n' needed there? You should only need  
> '\0', as a '\n'

> at the end is not required by any of the string functions used to  
> convert the
> address. I believe you could go with buf[RPCBIND_MAXUADDRLEN+1] for  
> the extra NUL only.

AFAICT, strict_strtoul() requires the '\n\0' termination.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
