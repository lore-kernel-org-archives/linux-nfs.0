From: Olaf Kirch <okir@suse.de>
Subject: Re: RE: Chuck's iostat patch
Date: Tue, 9 Mar 2004 15:15:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309141502.GB14419@suse.de>
References: <482A3FA0050D21419C269D13989C611302B07BB9@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jeremy McNicoll <jeremy@mcnicoll.ca>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0i9X-0002lg-I2
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:24:15 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0hcn-0006sa-Hs
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 05:50:25 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07BB9@lavender-fe.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Mar 09, 2004 at 05:58:46AM -0800, Lever, Charles wrote:
> i don't have a 2.6 version nor have i started any modification of
> iostat or sar.  i simply wanted to get agreement on APIs and exactly
> what metrics we are interested in providing.  as such this is only
> a prototype.  there are some ugly things that will change in the
> final version (nfs_count_this_op, i believe, is going away).

That is good. I very much prefer doing all the iostat stuff
inside the RPC layer, without having to modify NFS very much
(except for a single call to enable iostat collection for the
rpc_clnt)

> # optype   op count                bytes    retrans     errors

I would like to see separate in/out byte counts.

> there are a few problems with this solution.  one is that zeroing
> these counters is not atomic.  another is that umount is racy and
> can leave these data structures in a not so friendly state that
> could result in an oops.

I've addressed that by putting the rpc_clnt pointer into the proc dir
entry, and make it bump the refcount when the file is opened and call
rpc_release_client() when the file is closed.

> and i think we all agree that using
> seq_file is a much better way to export these metrics to user space.
> in the final version we will use sysfs instead of /proc.  it's
> not clear how to name the stat files uniquely -- today i'm using
> minor numbers, which is a hack.

It's a reasonable compromise. You can even use a simple monotonic counter
or the %p representation of the rpc_clnt pointer as the file name -
it should be up to iostat/sar to display something reasonable to the
user. You can help it by making nfs_show_options() give a hint which
iostat file corresponds to which mount.

> for use in the stat files.  in 2.6 we have superblock sharing, and
> i'm not sure what exactly that will mean for the "per-mountpoint"
> nature of this implementation.

Well, that is not an issue in this case I think. Only super blocks
with the same file handle get shared.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
