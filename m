From: Robin Humble <rjh@cita.utoronto.ca>
Subject: poor 2.6.2 read performance / max number of NFS mounts
Date: Mon, 9 Feb 2004 19:08:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040210000807.GA26140@falcon.cita.utoronto.ca>
References: <20030408035925.GB19119@marmot.cita.utoronto.ca> <16018.43382.626936.933137@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqLbL-00066o-AU
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:18:07 -0800
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqLTO-0006ys-2S
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:09:54 -0800
Received: from quail.cita.utoronto.ca ([128.100.76.6])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AqLTN-00005k-OW
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:09:53 -0800
Received: from cita.utoronto.ca (falcon.cita.utoronto.ca [128.100.76.51])
	by quail.cita.utoronto.ca (8.12.8/8.12.8) with ESMTP id i1A087TO001637
	for <nfs@lists.sourceforge.net>; Mon, 9 Feb 2004 19:08:07 -0500
Received: from falcon.cita.utoronto.ca (localhost [127.0.0.1])
	by cita.utoronto.ca (8.12.8/8.12.8) with ESMTP id i1A087TA003958
	for <nfs@lists.sourceforge.net>; Mon, 9 Feb 2004 19:08:07 -0500
Received: (from rjh@localhost)
	by falcon.cita.utoronto.ca (8.12.8/8.12.8/Submit) id i1A087tc003955
	for nfs@lists.sourceforge.net; Mon, 9 Feb 2004 19:08:07 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <16018.43382.626936.933137@notabene.cse.unsw.edu.au>
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


We are seeing very poor NFS _read_ performance with a standard 2.6.2
kernel. We get around 7MB/s over gigabit ethernet, wheras with a
2.4.21-pre2 (don't ask...) kernel we get more like 30MB/s.

ext3 is the filesystem. Uni-processor kernel, dual, or quad
(hyperthreading enabled) makes little difference. using a software
raid0 doesn't change much either. We are using fedora core 1 which has
nfs-utils-1.0.6-1.
We are doing nothing special with NFS mount options. Output from
'mount' looks like:
  ... type nfs (rw,nosuid,hard,intr,addr=...)
and the /etc/exports options look like
  ...(rw,no_root_squash,async)

performance testing:
Version  1.03      ------Sequential Output------ --Sequential Input- --Random-
                   -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
              Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP

kernel 2.4.21-pre2:
to local disk   2G 19968  97 34922  23 13903   5 22815  89 32775   6 176.4   0
over NFS        2G 20816  96 20009   6 15590  16 22655  94 30771   7 190.7   0

kernel 2.6.2:
to local disk   2G 29896  99 39256  20 12758   5 25267  69 35817   5 188.1   0
over NFS        2G 31321  99 37164  19  2111  71  7995  22  7497   1 197.8   0

so everything is better or ok with 2.6.2, except NFS reads and rewrites
which are amazingly slow. timing tests with dd instead of bonnie++ back
these up - ie. about 5x slower than you might expect.


A second (unrelated) issue:
A while ago I ping'd you guys about the 256 NFS mounts limit. This limit
still seems to be there in 2.6.2 kernels.

On Tue, Apr 08, 2003 at 08:50:30PM +1000, Neil Brown wrote:
>On Monday April 7, rjh@cita.utoronto.ca wrote:
>> When using autofs in an attempt to mount all backend disks at once we
>> hit the 256 mounts limitation and only get to about 246 backend disks
>> mounted - this is a pain :-/

Currently we have 268 nodes, and are hoping for a 10x larger future machine.
Having many disks mounted seems like it'll be a fairly normal event, not
some weird exception...???

Now that Linus increased the devices structure, can a proper NFS patch
be made please?
I updated NeilB's 2560 mount patch/hack so that it works with 2.6.2 and
it works ok, but it would be nice to have mainstream support for many
mounted disks.

Please CC me on any replies as I don't subscribe to the list.

cheers,
robin
--
   Dr Robin Humble       http://www.cita.utoronto.ca/~rjh/


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
