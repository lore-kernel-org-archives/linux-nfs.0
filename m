From: Filipe Brandenburger <branden@terra.com.br>
Subject: open O_EXCL works?
Date: Sun, 13 Mar 2005 14:23:38 -0300
Message-ID: <20050313141203.1044.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAWoW-000481-Ry
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 09:23:40 -0800
Received: from itapoa.terra.com.br ([200.154.55.227])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DAWoV-0007wu-Ne
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 09:23:40 -0800
Received: from estero.terra.com.br (estero.terra.com.br [200.154.55.138])
	by itapoa.terra.com.br (Postfix) with ESMTP id B84C530C974
	for <nfs@lists.sourceforge.net>; Sun, 13 Mar 2005 14:23:38 -0300 (BRT)
Received: from [200.176.1.176] (branden.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by estero.terra.com.br (Postfix) with ESMTP id 9E6AF3C01E
	for <nfs@lists.sourceforge.net>; Sun, 13 Mar 2005 14:23:38 -0300 (BRT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


Hello,

I'm trying to find out if open(O_CREAT|O_EXCL) works or not in NFS. I
read the RFC1813, and it says NFSv3 must implement it on the server, but
even so I don't know if the client is doing it reliably or not.

My server is a Netapp FAS940, my client is Linux RH7.3 with kernel 2.4.9-e.38smp
(the kernel is from RHAS2.1). I'm mounting the NFS with vers=3, the line
that is output in the "mount" command for this filesystem is:

10.10.4.7:/vol/vol3/mail7n03 on /var/spool/mail7n03-01 type nfs (rw,intr,vers=3,proto=udp,nolock,rsize=8192,wsize=8192,addr=10.10.4.7)

The fact is that I'm using tcpdump to find it out, but it seems to do an
"access" operation before the "create" operation to determine if the
file already exists (and fail the O_EXCL in that case), but this is not
atomic.

I also tried to test it with O_EXCL and without O_EXCL and take
tcpdump's, but they seem to be equal to me.

For example, when I executed this code:

[root@marova mail7n03-01]#  rm -f branden.txt; FILE=branden.txt perl -MFcntl -le'sysopen(H,$ENV{FILE},O_RDWR|O_CREAT|O_EXCL)||die "$!"'

I got this tcpdump for the create operation:

10:46:35.381897 10.10.105.244.1111971850 > 10.10.4.7.2049: 192 create fh Unknown/1 "branden.txt" (DF)
0x0000   4500 00dc 0000 4000 4011 b802 0a0a 69f4        E.....@.@.....i.
0x0010   0a0a 0407 031b 0801 00c8 a9f0 4247 580a        ............BGX.
0x0020   0000 0000 0000 0002 0001 86a3 0000 0003        ................
0x0030   0000 0008 0000 0001 0000 0044 0019 adcf        ...........D....
0x0040   0000 0013 6d61 726f 7661 2e74 6572 7261        ....marova.terra
0x0050   2e63 6f6d 2e62 7200 0000 0000 0000 0000        .com.br.........
0x0060   0000 0007 0000 0000 0000 0001 0000 0002        ................
0x0070   0000 0003 0000 0004 0000 0006 0000 000a        ................
0x0080   0000 0000 0000 0000 0000 0020 7700 0000        ............w...
0x0090   e74f a100 2000 0000 0000 0077 e74f a100        .O.........w.O..
0x00a0   b4f6 0012 7700 0000 e74f a100 0000 000b        ....w....O......
0x00b0   6272 616e 6465 6e2e 7478 7400 0000 0000        branden.txt.....
0x00c0   0000 0001 0000 81a4 0000 0000 0000 0000        ................
0x00d0   0000 0000 0000 0000 0000 0000                  ............
10:46:35.382105 10.10.4.7.2049 > 10.10.105.244.1111971850: reply ok 272 create fh Unknown/1
0x0000   4500 012c 26df 0000 4011 d0d3 0a0a 0407        E..,&...@.......
0x0010   0a0a 69f4 0801 031b 0118 91eb 4247 580a        ..i.........BGX.
0x0020   0000 0001 0000 0000 0000 0000 0000 0000        ................
0x0030   0000 0000 0000 0000 0000 0001 0000 0020        ................
0x0040   7700 0000 e74f a100 2000 0000 00ac 8d20        w....O..........
0x0050   b481 aa00 b4f6 0012 7700 0000 e74f a100        ........w....O..
0x0060   0000 0001 0000 0001 0000 01a4 0000 0001        ................
0x0070   0000 0000 0000 0000 0000 0000 0000 0000        ................
0x0080   0000 0000 0000 0000 0000 0000 0000 0000        ................
0x0090   0000 0000 1200 f6b4 0000 0000 00ac 8d20        ................
0x00a0   4234 443b 2c39 f1f8 4234 443b 2c39 f1f8        B4D;,9..B4D;,9..
0x00b0   4234 443b 2c39 f1f8 0000 0001 0000 0000        B4D;,9..........
0x00c0   0000 3000 4234 43bb 25f7 d170 4234 43bb        ..0.B4C.%..pB4C.
0x00d0   25f7 d170 0000 0001 0000 0002 0000 01ed        %..p............
0x00e0   0000 000f 0000 0208 0000 0208 0000 0000        ................
0x00f0   0000 3000 0000 0000 0000 3000 0000 0000        ..0.......0.....
0x0100   0000 0000 0000 0000 1200 f6b4 0000 0000        ................
0x0110   0000 0077 4234 442c 00d5 93c8 4234 443b        ...wB4D,....B4D;
0x0120   2c39 f1f8 4234 443b 2c39 f1f8                  ,9..B4D;,9..

And when I executed this code without the O_EXCL:

[root@marova mail7n03-01]#  rm -f branden.txt; FILE=branden.txt perl -MFcntl -le'sysopen(H,$ENV{FILE},O_RDWR|O_CREAT)||die "$!"'

I got this tcpdump for the create operation, that seemed the same,
except of course for being a different run (different timestamps, and
other insignificant differences):

10:51:44.966999 10.10.105.244.1196120330 > 10.10.4.7.2049: 192 create fh Unknown/1 "branden.txt" (DF)
0x0000   4500 00dc 0000 4000 4011 b802 0a0a 69f4        E.....@.@.....i.
0x0010   0a0a 0407 031a 0801 00c8 a2b8 474b 590a        ............GKY.
0x0020   0000 0000 0000 0002 0001 86a3 0000 0003        ................
0x0030   0000 0008 0000 0001 0000 0044 0019 af04        ...........D....
0x0040   0000 0013 6d61 726f 7661 2e74 6572 7261        ....marova.terra
0x0050   2e63 6f6d 2e62 7200 0000 0000 0000 0000        .com.br.........
0x0060   0000 0007 0000 0000 0000 0001 0000 0002        ................
0x0070   0000 0003 0000 0004 0000 0006 0000 000a        ................
0x0080   0000 0000 0000 0000 0000 0020 7700 0000        ............w...
0x0090   e74f a100 2000 0000 0000 0077 e74f a100        .O.........w.O..
0x00a0   b4f6 0012 7700 0000 e74f a100 0000 000b        ....w....O......
0x00b0   6272 616e 6465 6e2e 7478 7400 0000 0000        branden.txt.....
0x00c0   0000 0001 0000 81a4 0000 0000 0000 0000        ................
0x00d0   0000 0000 0000 0000 0000 0000                  ............
10:51:44.967211 10.10.4.7.2049 > 10.10.105.244.1196120330: reply ok 272 create fh Unknown/1
0x0000   4500 012c f3e0 0000 4011 03d2 0a0a 0407        E..,....@.......
0x0010   0a0a 69f4 0801 031a 0118 56a8 474b 590a        ..i.......V.GKY.
0x0020   0000 0001 0000 0000 0000 0000 0000 0000        ................
0x0030   0000 0000 0000 0000 0000 0001 0000 0020        ................
0x0040   7700 0000 e74f a100 2000 0000 00ac 8d20        w....O..........
0x0050   b581 aa00 b4f6 0012 7700 0000 e74f a100        ........w....O..
0x0060   0000 0001 0000 0001 0000 01a4 0000 0001        ................
0x0070   0000 0000 0000 0000 0000 0000 0000 0000        ................
0x0080   0000 0000 0000 0000 0000 0000 0000 0000        ................
0x0090   0000 0000 1200 f6b4 0000 0000 00ac 8d20        ................
0x00a0   4234 4571 1575 2a00 4234 4571 1575 2a00        B4Eq.u*.B4Eq.u*.
0x00b0   4234 4571 1575 2a00 0000 0001 0000 0000        B4Eq.u*.........
0x00c0   0000 3000 4234 4562 2eca 0ae8 4234 4562        ..0.B4Eb....B4Eb
0x00d0   2eca 0ae8 0000 0001 0000 0002 0000 01ed        ................
0x00e0   0000 000f 0000 0208 0000 0208 0000 0000        ................
0x00f0   0000 3000 0000 0000 0000 3000 0000 0000        ..0.......0.....
0x0100   0000 0000 0000 0000 1200 f6b4 0000 0000        ................
0x0110   0000 0077 4234 442c 00d5 93c8 4234 4571        ...wB4D,....B4Eq
0x0120   1575 2a00 4234 4571 1575 2a00                  .u*.B4Eq.u*.



I also tried to find something from the kernel source, I looked into the
2.4.18 source that I had in my hands, and I found out inside
fs/nfs/nfs3proc.c this comments:

/*
 * Create a regular file.
 * For now, we don't implement O_EXCL.
 */
static int
nfs3_proc_create(struct inode *dir, struct qstr *name, struct iattr *sattr,
                 int flags, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
{
[...]

But the strange is that the code then goes and implements exactly what
O_EXCL is to do:

[...]
        arg.createmode = NFS3_CREATE_UNCHECKED;
        if (flags & O_EXCL) {
                arg.createmode  = NFS3_CREATE_EXCLUSIVE;
                arg.verifier[0] = jiffies;
                arg.verifier[1] = current->pid;
        }
[...]

I don't know who is calling this function, and if who is calling this
funcion is never using O_EXCL and implementing that check at that level.
Is it the case?

Well, I hope you can answer my questions, I can send you more
information about the problem if that's the case (tcpdump's, etc.).

Thanks in advance,
Filipe



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
