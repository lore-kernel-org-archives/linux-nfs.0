From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 11:43:24 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>
References: <15697.18944.451371.303514@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cTuC-0004gX-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 09:43:28 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15697.18944.451371.303514@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, 7 Aug 2002, Trond Myklebust wrote:

> >>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:
> 
>      > On Wednesday 07 August 2002 11:17 am, Trond Myklebust wrote:
>     >> >>>>> " " == Rex Dieter <rdieter@math.unl.edu> writes:
>     >> > It depends.  I agree that defaulting to 'sync' is not a bug.
>     >> > I do *not* agree that 50k writes is not a bug.
>     >>
>     >> NFSv2 or v3?
> 
>      > I tried primarily v3, but I think I remember testing v2 as
>      > well, with similar results.
> 
> If you are getting that performance with v3, then it does indeed sound
> like a bug somewhere. Try with a stock 2.4.19 kernel instead...

I just tested things with a test kernel (2.4.18-7) from redhat, and it 
sync write speeds were again way up there.  Problem fixed, as far as I'm 
concerned... hopefully, they'll release an errata soon.

-- 
Rex A. Dieter			rdieter@unl.edu 
Computer System Administrator 	http://www.math.unl.edu/~rdieter/
Mathematics and Statistics  		 
University of Nebraska Lincoln



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
