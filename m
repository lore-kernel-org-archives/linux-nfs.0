From: Paul Haas <paulh@iware.com>
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Fri, 6 Dec 2002 12:58:14 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0212061216100.1411-100000@bandit.sdrc.com>
References: <CFEAJJEGMGECBCJFLGDBAEHNCJAA.hammer@clarkisland.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Whiting <ewhiting@amis.com>, NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heimdall.sdrc.com ([146.122.132.195] helo=sdrc.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18KMl4-0002qa-00
	for <nfs@lists.sourceforge.net>; Fri, 06 Dec 2002 09:59:26 -0800
To: Jake Hammer <hammer@clarkisland.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBAEHNCJAA.hammer@clarkisland.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

My apologies in advance  if I get any of the attributions wrong.

On Wed, 4 Dec 2002, Jake Hammer wrote:

> 2 x 8 port 3ware IDE RAID cards, RAID 5 done in software by 2.4.19 IBM EVMS.
> Filesystem is EXT3, mounted with defaults. 14 disks.

So what is the effective block size across the RAID array?  Correct me if
I'm wrong. I'm guessing 48k bytes.  Each stripe has 6 data disks and 1
parity disk.  The block size on each data disk is 8k bytes.  So the
smallest write is 48kbytes of data and 8kbytes of parity.

In another message you wrote:

> Mount =
> mount -o proto=udp,vers=2,wsize=32768,rsize=32768 bigbox:/space

Doesn't NFS default to synchronous writes?

To write the first 32kbytes of data in a file, NFS actually writes 48k,
then it waits for that data to get to the disk.  The next 32kbytes will
straddle two 48kbyte "blocks", so the next write will actually write
96kbytes to the disks.  The third 32k won't straddle a block boundary, so
it will be like the first 32k, 48k of data disk traffic.  So for every 96k
of writes, you'll see 192k of disk traffic.

Local writes aren't syncronous, so 96kbytes of writes are 96kbytes.

In other messages you wrote about the NFS write only case:

> I am able to see 45MB/sec writes

And for the local write only case you wrote:

> Local write is ~100MB/sec

That's about the 1 to 2 ratio I would expect.

Now add a bunch of other disk I/O activity to trash the caches that are
internal to each disk.

Each partial block write that doesn't straddle blocks will involve reading
the whole 48kbyte block, modifying the changed bits, and writing 48bytes
back out.  Double that for the writes that straddle block boundaries.
Performance will really, really suck, because now there are bunchs of
seek delays.

You also wrote:

> performance drops to 3MB/sec (three MB/s)!

Yup, that really, really sucks.

> To summarize:
>
> Local disk is fast read, write, and read+write. NFS is sort of fast for read
> and for write, but it *utterly* dies on read + write UDP and TCP. Network is
> clean.

> > I would like to see a solution to this sort of problem as well.

> Glad you're seeing it as well. I hope it can be sorted out.

Can you try a combination of mirroring and striping instead of RAID 5 and
see what you get?

If it is possible, make the block sizes match.  I don't think it is easy
to make the NFS block size 48k.  If you could try 4 data disks per parity
disk, then it might be reasonable.

> Thanks,

> Jake


-- 
Paul Haas                                                  EDS
2600 Green Road, Suite 100,  Ann Arbor, MI 48105
paulh@iware.com      http://www.iware.com       (734) 623-5808









-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
