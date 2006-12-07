From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [GIT] Please pull the NFS client update for 2.6.19
Date: Wed, 6 Dec 2006 18:17:14 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0612061812010.3615@woody.osdl.org>
References: <1165424156.5744.10.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0612061713270.3542@woody.osdl.org>
	<1165455261.5744.71.camel@lade.trondhjem.org>
	<1165455602.5744.73.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1165455602.5744.73.camel@lade.trondhjem.org>
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



On Wed, 6 Dec 2006, Trond Myklebust wrote:
> 
> Hmm... Have the workqueue updates been pushed out yet? I can't seem to
> pull them from git.kernel.org.

The kernel.org mirroring has been really flaky lately.

If you have an account, you can use master.kernel.org to get things 
without mirroring delays.

And if not, I'd be happy to push to other places too, but the reason 
kernel.org tends to occasionally get slow at mirroring is probably because 
it does get a lot of traffic. So..

		Linus
