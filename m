From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [NFS] Missing handling for
	NFS4ERR_OLD_STATEID	in	nfs4_handle_exception?
Date: Thu, 12 Apr 2007 13:49:16 -0400
Message-ID: <461E711C.9040202@poochiereds.net>
References: <1175616589.3531.8.camel@dyn9047022153>	
	<461E1F2C.7000605@poochiereds.net>
	<1176399064.6664.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1176399064.6664.22.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
> On Thu, 2007-04-12 at 07:59 -0400, Jeff Layton wrote:
> 
>> This sounds sort of like addressing the symptom and not the real 
>> problem, however. The real question ought to be why you're getting 
>> OLD_STATEID errors back from the server here. There can be legit 
>> reasons, but these errors ought to be fairly rare. I generally only have 
>> seen them when processes are signalled while RPC requests are in flight.
> 
> OLD_STATEID usually occurs if an OPEN or an OPEN_DOWNGRADE gets sent
> that changes the current stateid while a READ or WRITE to the same file
> is in flight.
> 
> It is generally a rare event, and so it tends to be much easier to deal
> with by simply resending the READ/WRITEs with the updated stateid rather
> than adding an expensive locking scheme for excluding READ/WRITE while
> the OPEN/OPEN_DOWNGRADE is in progress.
> 
> Cheers,
>   Trond
> 

Ahh that makes sense. I must have misunderstood the circumstances where 
I was seeing it. Thanks for clarifying.

-- Jeff
