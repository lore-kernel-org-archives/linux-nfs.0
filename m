From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [RFC] NFS client changes - page kmap() in the RPC layer.
Date: Sun, 5 May 2002 15:27:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15573.13104.24494.347422@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>, nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174M2w-0000xl-00
	for <nfs@lists.sourceforge.net>; Sun, 05 May 2002 06:27:26 -0700
To: "Chuck Lever" <cel@monkey.org>,
    "Kendrick M. Smith" <kmsmith@umich.edu>
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

Hi,

  One of the reported problems that remain to be fixed in the client
RPC layer when using a HIGHMEM system, is that we can deadlock on
'kmap()'.

The problem is that there is a limited pool of addresses available to
the kmap() operation. The current design is based on the premise that
no single process will 'hold' more than one kmapped page for any
extended period of time.
The NFS layer breaks this premise, since each read/write kmap()s the
pages at the beginning of the RPC call, and only kunmap()s at the
end. If, say, a server is down for an extended period, so that all
RPC calls loop and retry, then we might end up exhausting the entire
resource pool.

The solution is to move the kmapping operation into the RPC
socket layer. There are only 2 places where we need kmap:

  - When calling sock_sendmsg()
  - When copying the reply from the server into pages.

Of course, in order to do so, we need to teach the RPC layer to deal
with pages, rather than page kmap() addresses.

The 2 patches in

  http://www.fys.uio.no/~trondmy/src/2.4.19-pre8/alpha

do precisely that. The patch linux-2.4.19-fix_kmap.dif introduces a
new 'RPC buffer' type defined as follows:

struct xdr_buf {
	struct iovec	head[1],	/* RPC header + non-page data */
			tail[1];	/* Appended after page data */

	struct page **	pages;		/* Array of contiguous pages */
	unsigned int	page_base,	/* Start of page data */
			page_len;	/* Length of page data */

	unsigned int	len;		/* Total length of data */
};

and applies it to the NFS write code.
The patch linux-2.4.19-fix_kmap2.dif changes the various NFS 'read'
operations (read, readdir, readlink) to use this structure.

The patches will apply on top of linux-2.4.19-NFS_ALL.dif, although
you will have to disable the NFS direct I/O code, as I haven't
yet gotten around to fixing that (Chuck?).

Comments please? How does this for instance affect the NFSv4 code?

Please note: The two patches do not include code to make use of the
TCP_CORK + sendpage() zero copy socket interface, but doing so is
trivial if RPC were to use the above structure.

Cheers,
   Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
