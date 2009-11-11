From: Patroklos Argyroudis <argp@census-labs.com>
Subject: [PATCH] sunrpc: off-by-two stack buffer overflow in function
 rpc_uaddr2sockaddr()
Date: Wed, 11 Nov 2009 13:02:29 +0200
Message-ID: <20091111110229.GA12676@evola>
References: <bug-14546-10286@http.bugzilla.kernel.org/>
 <20091110152908.7558a471.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091110152908.7558a471.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is an off-by-two stack buffer overflow in function rpc_uaddr2sockaddr()
of file net/sunrpc/addr.c in the Linux kernel SUNRPC implementation.
 
The function rpc_uaddr2sockaddr() that is used to convert a universal address
to a socket address takes as an argument the size_t variable uaddr_len (the
length of the universal address string). The stack buffer buf is declared in
line 315 to be of size RPCBIND_MAXUADDRLEN. If the passed argument uaddr_len is
equal to RPCBIND_MAXUADDRLEN then the check at line 319 passes and then at
lines 324 and 325 there are two out-of-bounds assignments:
 
    319         if (uaddr_len > sizeof(buf))
    320                 return 0;
 ...
    324         buf[uaddr_len] = '\n';
    325         buf[uaddr_len + 1] = '\0';

Signed-off-by: Patroklos Argyroudis <argp@census-labs.com>
---

--- linux-2.6/net/sunrpc/addr.c.orig    2009-11-11 12:33:04.000000000 +0200
+++ linux-2.6/net/sunrpc/addr.c 2009-11-11 12:33:32.000000000 +0200
@@ -316,7 +316,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
    unsigned long portlo, porthi;
    unsigned short port;
 
-   if (uaddr_len > sizeof(buf))
+   if (uaddr_len > sizeof(buf) - 2)
        return 0;
 
    memcpy(buf, uaddr, uaddr_len);

