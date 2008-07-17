From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op
	header decoding error
Date: Thu, 17 Jul 2008 16:20:53 +0300
Message-ID: <487F4735.40700@panasas.com>
References: <47F0F6AB.3030302@panasas.com>	
	<1206974900-368-1-git-send-email-bhalevy@panasas.com>	
	<1207002349.15341.15.camel@heimdal.trondhjem.org>	
	<47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>	
	<4824E08E.6070401@panasas.com>
	<1210440276.12927.0.camel@localhost>	
	<48277F7B.2060307@panasas.com> <486D110F.1010608@panasas.com>	
	<1216159035.7981.70.camel@localhost> <487DAF6F.10404@panasas.com>	
	<1216213058.7786.2.camel@localhost> <487DF62C.80501@panasas.com>
	<1216296542.7453.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1216296542.7453.19.camel@localhost>
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

On Jul. 17, 2008, 15:09 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2008-07-16 at 16:22 +0300, Benny Halevy wrote:
>> On Jul. 16, 2008, 15:57 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>>> Why do we need to handle OP_ILLEGAL in the first place? This is the
>>> client; it isn't supposed to send illegal operations...
>> Right, but it helps in the development process when dealing with
>> a broken version of the server or the client to pass a less
>> generic error (-EOPNOTSUPP) up the stack rather than -EIO.
> 
> NFS4ERR_OP_ILLEGAL literally means "this operation isn't even listed in
> the 4.0/4.1 RFC". That's out in EYOUUTTERLYINSANECLIENT territory, and
> so the current mapping to EOPNOTSUPP is just wrong.

FWIW, we currently map NFS4ERR_NOTSUPP to -ENOTSUPP and
NFS4ERR_OP_ILLEGAL to -EOPNOTSUPP so one can distinct between
the two cases, even if the latter mapping is wrong.

I'm not sure if there's an available error code that would
describe this NFS4ERR_OP_ILLEGAL perfectly, -EINVAL might
be reasonable but I it's not very distinctive. Maybe we should
add one to include/linux/errno.h?

> 
> NFS4ERR_NOTSUPP is the correct return value if a server doesn't (yet)
> support an operation.
> 
> 
> 

Agreed.

Just that we had a bug in the server that caused us to return
NFS4ERR_OP_ILLEGAL for unimplemented ops rather than NFS4ERR_NOTSUPP.
That's a condition I really want to be aware of while developing the
server.

Benny
