From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: NFS & Clustering
Date: 04 Sep 2002 09:40:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1031157608.25370.8.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: emanuel.quass@temic.com
In-Reply-To: <200209041824.46264.emanuel.quass@temic.com>
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

On Wed, 2002-09-04 at 09:24, Emanuel Quass wrote:

> but doesn't it work if you share /var/lib/nfs/* (containing etab, rmtab, sm,  
> sm.bak, state, xtab)?

Not reliably.  You're left with a single point of failure, for one
thing.  You also have races between one server permitting a mount and
others knowing that the mount has been allowed, which can confuse
clients.

	<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
