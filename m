From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: Sat, 5 Oct 2002 21:09:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021005210957.A23389@lucon.org>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net> <shsy99ddayi.fsf@charged.uio.no> <1033793310.4626.0.camel@camp4.serpentine.com> <shsd6qovozl.fsf@charged.uio.no> <1033851316.29937.37.camel@plokta.s8.com> <15775.24289.796995.465654@charged.uio.no> <20021005164157.B19687@lucon.org> <1033876862.18607.0.camel@camp4.serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-88-146.client.attbi.com ([12.234.88.146] helo=lucon.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17y2ju-0005DT-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 21:09:58 -0700
To: Bryan O'Sullivan <bos@serpentine.com>
In-Reply-To: <1033876862.18607.0.camel@camp4.serpentine.com>; from bos@serpentine.com on Sat, Oct 05, 2002 at 09:01:02PM -0700
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

On Sat, Oct 05, 2002 at 09:01:02PM -0700, Bryan O'Sullivan wrote:
> On Sat, 2002-10-05 at 16:41, H. J. Lu wrote:
> 
> > It must be a new bug. I used to have Quad P/II Xeon with 8GB RAM.
> > I had no problem with its NFS server performance. Also my modified
> > kernel based on RedHat kernel 2.4.18-14 has no NFS server problem
> > with 1.5GB RAM.
> 
> You're not using Trond's NFS_ALL patch, though, right?  That has some
> substantial modifications to the source.
> 

RedHat 2.4.18-14 is kernel 2.4.18 + tons of patches. I don't think
it has straight Trond's NFS_ALL patch. But it does have some NFS
changes. The only NFS related complaint I have is they default the
NFS V3 block size to 4096 which kills the NFS client performance. I
believe they put that in to avoid crashing NetApp. I changed it to
8192 and I am quite happy with its NFS performance.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
