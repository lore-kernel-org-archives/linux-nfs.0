From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 1/7] SUNRPC: Fix a race in xs_tcp_state_change()
Date: Thu, 08 Nov 2007 11:12:40 -0500
Message-ID: <1194538360.7655.12.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003940.13713.65472.stgit@heimdal.trondhjem.org>
	<47323A62.9000803@oracle.com>
	<1194474763.7504.57.camel@heimdal.trondhjem.org>
	<47332DF5.6050202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47332DF5.6050202@oracle.com>
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


On Thu, 2007-11-08 at 10:40 -0500, Chuck Lever wrote:
> That's fine.  But you still clear XPRT_CLOSE_WAIT twice in a row in 
> xprt_autoclose, at least for the socket transport method.  Either clear 
> it in xprt_autoclose, or clear it in the tranport close methods.  Not 
> both.  It doesn't break anything, but it is confusing to human readers.

Yup. I'll fix it up.

> I'm still a little confused about which state flags are supposed to be 
> managed entirely by the transports, and which by the generic logic.  Can 
> you perhaps add a block comment in xprt.h where the flags are defined 
> that describes how these flags are supposed to be used?  Actually, even 
> better would be to have a separate state word for the transports, 
> defined in their private transport structure.  The 
> non-connection-oriented transports wouldn't need to manipulate the 
> specific flags.

Well... Some of them want to be publicly readable, but only writable by
certain subsystems. The XPRT_BOUND and XPRT_CONNECTED flags are two
examples of this. Then there is fully private stuff like XPRT_BINDING,
XPRT_CONNECTING, and XPRT_CLOSING.

I think the right thing to do is to keep public functions like
xprt_connected(), and xprt_bound() for use by the RPC client state
machine in xprt.h, and then perhaps move the currently public
'manipulator' functions xprt_set_connected(), xprt_clear_connected(),...
into a private header file for use by xprtsock.c, and
xprtrdma/transport.c.

Trond
