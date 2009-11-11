From: Fabio Olive Leite <fabio.olive@gmail.com>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow
 in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Wed, 11 Nov 2009 10:34:42 -0200
Message-ID: <20091111103442.03a6a06d@gmail.com>
References: <bug-14546-10286@http.bugzilla.kernel.org/>
	<20091110152908.7558a471.akpm@linux-foundation.org>
	<967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
	<20091111075128.GA28323@evola>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Linux Network Developers <netdev@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Patroklos Argyroudis <argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:56877 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbZKKMes (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 07:34:48 -0500
In-Reply-To: <20091111075128.GA28323@evola>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2009-11-11 Patroklos Argyroudis wrote:
> There is no need to increase the size of the buffer since the new
> check (if (uaddr_len > sizeof(buf) - 2)) will terminate the function
> in case the valid universal address is RPCBIND_MAXUADDRLEN bytes.

On a second note, why is '\n' needed there? You should only need '\0',
as a '\n' at the end is not required by any of the string functions use=
d
to convert the address.

I believe you could go with buf[RPCBIND_MAXUADDRLEN+1] for the extra
NUL only.

Cheers,
=46=C3=A1bio Oliv=C3=A9
--=20
ex sed lex awk yacc, e pluribus unix, amem
na matem=C3=A1tica das id=C3=A9ias, permuta =C3=A9 igual a adi=C3=A7=C3=
=A3o
e um debate inteligente implementa a multiplica=C3=A7=C3=A3o
