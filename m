From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: Sat, 5 Oct 2002 16:41:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021005164157.B19687@lucon.org>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net> <shsy99ddayi.fsf@charged.uio.no> <1033793310.4626.0.camel@camp4.serpentine.com> <shsd6qovozl.fsf@charged.uio.no> <1033851316.29937.37.camel@plokta.s8.com> <15775.24289.796995.465654@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan O'Sullivan <bos@serpentine.com>,
	"Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-88-146.client.attbi.com ([12.234.88.146] helo=lucon.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xyYY-0005A5-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 16:41:58 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15775.24289.796995.465654@charged.uio.no>; from trond.myklebust@fys.uio.no on Sat, Oct 05, 2002 at 11:51:29PM +0200
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Sat, Oct 05, 2002 at 11:51:29PM +0200, Trond Myklebust wrote:
> >>>>> " " == Bryan O'Sullivan <bos@serpentine.com> writes:
> 
>      > I'll try to take a look on a local system in the next few days.
>      > Are you or Roger using Jens Axboe's block-highmem patch or any
>      > of the drivers it touches?  Knowing this should help control
>      > for at least one variable.
> 
> I've seen the behaviour on stock 2.4.19 and 2.4.20-preX. I haven't
> tested any of Jens' patches...
> 

It must be a new bug. I used to have Quad P/II Xeon with 8GB RAM.
I had no problem with its NFS server performance. Also my modified
kernel based on RedHat kernel 2.4.18-14 has no NFS server problem
with 1.5GB RAM.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
