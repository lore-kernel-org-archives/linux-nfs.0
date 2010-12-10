Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21123 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138Ab0LJWXV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 17:23:21 -0500
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls than offered by the -i option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101210215758.GA15059@ti93.telemetry-investments.com>
Date: Fri, 10 Dec 2010 17:22:43 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc <libtirpc-devel@lists.sourceforge.net>
Message-Id: <56D846C6-C941-4ACC-9A8B-DFDC9296C2CE@oracle.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com> <4D016F44.3020002@RedHat.com> <20101210023847.GB15344@ti93.telemetry-investments.com> <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com> <4D024D70.7040108@RedHat.com> <FD9D05EF-FB57-45FB-BBDC-38E3B92D54AA@oracle.com> <20101210171014.GA5280@ti93.telemetry-investments.com> <0F5A7F8B-AA38-4653-BCDC-B192FF790F51@oracle.com> <20101210215758.GA15059@ti93.telemetry-investments.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Correcting the Cc:, apologies.

On Dec 10, 2010, at 4:57 PM, Andrew J. Schorr wrote:

> Adding CC libtirpc-devel@sourceforge.net:
> 
> On Fri, Dec 10, 2010 at 12:14:47PM -0500, Chuck Lever wrote:
>> The libtirpc legacy API should be the same as the glibc RPC API.  If you spot any truly non-ABI compatible changes, or have any other related questions, please let us know.  (we should probably cc libtirpc-devel@sourceforge.net).
>> 
> 
> I have not inspected closely yet, but did notice that the XDR structure
> has changed.  In /usr/include/rpc/xdr.h, there is this:
> 
> struct XDR
>  {
>    enum xdr_op x_op;           /* operation; fast additional param */
>    struct xdr_ops
>      {
>        bool_t (*x_getlong) (XDR *__xdrs, long *__lp);
>        /* get a long from underlying stream */
>        bool_t (*x_putlong) (XDR *__xdrs, __const long *__lp);
>        /* put a long to " */
>        bool_t (*x_getbytes) (XDR *__xdrs, caddr_t __addr, u_int __len);
>        /* get some bytes from " */
>        bool_t (*x_putbytes) (XDR *__xdrs, __const char *__addr, u_int __len);
>        /* put some bytes to " */
>        u_int (*x_getpostn) (__const XDR *__xdrs);
>        /* returns bytes off from beginning */
>        bool_t (*x_setpostn) (XDR *__xdrs, u_int __pos);
>        /* lets you reposition the stream */
>        int32_t *(*x_inline) (XDR *__xdrs, u_int __len);
>        /* buf quick ptr to buffered data */
>        void (*x_destroy) (XDR *__xdrs);
>        /* free privates of this xdr_stream */
>        bool_t (*x_getint32) (XDR *__xdrs, int32_t *__ip);
>        /* get a int from underlying stream */
>        bool_t (*x_putint32) (XDR *__xdrs, __const int32_t *__ip);
>        /* put a int to " */
>      }
>     *x_ops;
>    caddr_t x_public;           /* users' data */
>    caddr_t x_private;          /* pointer to private data */
>    caddr_t x_base;             /* private used for position info */
>    u_int x_handy;              /* extra private word */
>  };
> 
> Whereas the new tirpc/rpc/xdr.h has this:
> 
> typedef struct __rpc_xdr {
>        enum xdr_op     x_op;           /* operation; fast additional param */
>        const struct xdr_ops {
>                /* get a long from underlying stream */
>                bool_t  (*x_getlong)(struct __rpc_xdr *, long *);
>                /* put a long to " */
>                bool_t  (*x_putlong)(struct __rpc_xdr *, const long *);
>                /* get some bytes from " */
>                bool_t  (*x_getbytes)(struct __rpc_xdr *, char *, u_int);
>                /* put some bytes to " */
>                bool_t  (*x_putbytes)(struct __rpc_xdr *, const char *, u_int);
>                /* returns bytes off from beginning */
>                u_int   (*x_getpostn)(struct __rpc_xdr *);
>                /* lets you reposition the stream */
>                bool_t  (*x_setpostn)(struct __rpc_xdr *, u_int);
>                /* buf quick ptr to buffered data */
>                int32_t *(*x_inline)(struct __rpc_xdr *, u_int);
>                /* free privates of this xdr_stream */
>                void    (*x_destroy)(struct __rpc_xdr *);
>                bool_t  (*x_control)(struct __rpc_xdr *, int, void *);
>        } *x_ops;
>        char *          x_public;       /* users' data */
>        void *          x_private;      /* pointer to private data */
>        char *          x_base;         /* private used for position info */
>        u_int           x_handy;        /* extra private word */
> } XDR;
> 
> 
> As you can see, the structure has changed (some methods added and others
> removed).  As a result, my code to implement a new XDR type no longer compiles,
> and will require porting (which presumably will not be major).
> 
> So I claim that tirpc is not fully ABI compatible with the legacy RPC
> implementation.

Thanks for the report.  We are aware of a handful of other minor instances, so it is true that there is not full ABI compatibility.  For most RPC applications of sufficient complexity, the differences are not significant.  At a guess, the use of RPCL and rpcgen to construct your XDR type might be helpful for avoiding this problem.

The XDR struct is not part of the published RPC API, is it?  See Sun doc 816-1435.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




