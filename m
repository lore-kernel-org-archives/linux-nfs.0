From: Martin Siegert <siegert@sfu.ca>
Subject: Re: limit on filesystem size?
Date: Fri, 2 Aug 2002 13:22:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020802202210.GA28263@stikine.ucs.sfu.ca>
References: <20020801195309.GA26793@stikine.ucs.sfu.ca> <shs7kja48km.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rm-rstar.sfu.ca ([142.58.120.21])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aiwH-0003um-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 13:22:21 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs7kja48km.fsf@charged.uio.no>
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

Thanks, Trond.

On Thu, Aug 01, 2002 at 10:39:53PM +0200, Trond Myklebust wrote:
> >>>>> " " == Martin Siegert <siegert@sfu.ca> writes:
> 
>      > Hello, we are in the planning process for the setup of a large
>      > (~ 100 TB) NFS server. My understanding is that there is a
>      > limit of 2TB for filesystem sizes for local (!) filesystems
>      > under Linux (at least for ext2/ext3; I am not sure about xfs).
> 
>      > My question really is: is there a limit for the filesystem size
>      > that a Linux NFS client (2.4.18 or the upcoming 2.4.19 kernel)
>      > can mount from a (possibly non-Linux) NFS server?  E.g., can I
>      > mount a 20TB filesystem under Linux?
> 
>      > (I've asked this question on the beowulf mailing list and the
>      > answer was no. Now I ask the experts - hoping for a different
>      > answer :-)
> 
> If you can mount it, then you can export it...

Please, bear with me - I am by no means an expert on these issues.
But my impression was that the problem is in include/linux/blkdev.h

struct request {
...
        unsigned long sector;

with results in a (local) filesystem size limit of 2TB (unless sectors
larger than 512 bytes are used).

Am I understanding correctly that you are telling me that this does not
apply to NFS and that despite this definition I could even reexport
(user space NFS?) such a filesystem?

> For NFSv2 there is a 32-bit size limit on the files you can export
> whereas for NFSv3, that limit is 64-bits, but those limits are
> *per-file*.

Yes, I do not have any problems anymore with files larger than 2GB.

> Otherwise, you might run into problems when you try to run 'df' in
> order to read filesystem statistics (NFSv2, the limit is 41-bit
> - NFSv3 the limit is 64-bit) but that shouldn't really be a critical
>  feature.

Agreed. That wouldn't be a big problem. As long as I can read and write
to such a 20TB NFS mounted filesystem everything would be secondary.

Thanks again,

Cheers,
Martin


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
