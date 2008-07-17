From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op
	header decoding error
Date: Thu, 17 Jul 2008 08:09:02 -0400
Message-ID: <1216296542.7453.19.camel@localhost>
References: <47F0F6AB.3030302@panasas.com>
	<1206974900-368-1-git-send-email-bhalevy@panasas.com>
	<1207002349.15341.15.camel@heimdal.trondhjem.org>
	<47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>
	<4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>
	<48277F7B.2060307@panasas.com>  <486D110F.1010608@panasas.com>
	<1216159035.7981.70.camel@localhost>  <487DAF6F.10404@panasas.com>
	<1216213058.7786.2.camel@localhost>  <487DF62C.80501@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <487DF62C.80501@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-07-16 at 16:22 +0300, Benny Halevy wrote:
> On Jul. 16, 2008, 15:57 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > Why do we need to handle OP_ILLEGAL in the first place? This is the
> > client; it isn't supposed to send illegal operations...
> 
> Right, but it helps in the development process when dealing with
> a broken version of the server or the client to pass a less
> generic error (-EOPNOTSUPP) up the stack rather than -EIO.

NFS4ERR_OP_ILLEGAL literally means "this operation isn't even listed in
the 4.0/4.1 RFC". That's out in EYOUUTTERLYINSANECLIENT territory, and
so the current mapping to EOPNOTSUPP is just wrong.

NFS4ERR_NOTSUPP is the correct return value if a server doesn't (yet)
support an operation.
