From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: Need help interpreting numbers
Date: Tue, 18 Feb 2003 16:30:39 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302181608310.23186-100000@glenfiddich.cse.ogi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from franklin.cse.ogi.edu ([129.95.40.7])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lI8L-0007FC-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 16:30:46 -0800
Received: from euclid.cse.ogi.edu (euclid.cse.ogi.edu [129.95.41.95])
	by franklin.cse.ogi.edu (8.12.6/8.12.6) with ESMTP id h1J0UdC5021770
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 16:30:39 -0800 (PST)
Received: from glenfiddich.cse.ogi.edu (glenfiddich.cse.ogi.edu [129.95.33.101])
	(authenticated bits=0)
	by euclid.cse.ogi.edu (8.12.5/8.12.5) with ESMTP id h1J0UdNP032539
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 16:30:39 -0800
To: nfs@lists.sourceforge.net
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

I'm a bit stymied over some iostat comparisons I've been making 
between a couple different kernels. If someone could help me with the 
numbers...

I've got a Linux server fronting a RAID array (I mentioned this a week 
or so ago, but the implementation details are probably unimportant). 
I did some testing with the SGI-built XFS-enabled version of Red Hat's 
2.4.18 kernel (2.4.18-18SGI_XFS_1.2pre5smp).

I pointed a half-dozen NFS clients at the exported filesystem and had 
them run iozone simultaneously. Here's a representative except of the 
server's iostat output while the test was going on (sorry for the line 
wrapping):

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 4040.53  0.00 311.57    0.00 32864.67     0.00 
16432.33   105.48   194.33   21.00   3.21 100.00

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 4433.53  0.00 379.63    0.00 37231.30     0.00 
18615.65    98.07   212.70   26.69   2.63 100.00

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 4061.17  0.00 183.80    0.00 33039.00     0.00 
16519.50   179.76   231.48   59.67   5.44 100.00


Today, I built and installed 2.4.20 from kernel.org with XFS patch
2.4.20-2003-01-14_00:43_UTC and Trond's NFS_ALL patch. Under a similar 
test environment, the numbers are remarkably different, e.g.,

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 1215.67  0.00 356.38    0.00 11309.88     0.00  
5654.94    31.74   114.67   32.16   2.80  99.90

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 1440.73  0.00 370.63    0.00 13042.82     0.00  
6521.41    35.19    74.39   20.06   2.69  99.82

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
avgrq-sz avgqu-sz   await  svctm  %util
/dev/sda     0.00 1558.33  0.00 356.70    0.00 13785.85     0.00  
6892.93    38.65    59.97   16.80   2.80  99.80

The number of bytes getting written to disk is less than half that
reported above, but the await and svctm times are consistently lower
too (as is %util). Also, the await/svctm numbers in the home-brewed 
kernel are much more consistent; they bounce around a *lot* more under 
the SGI/Red Hat kernel.

Oddly, however, when the clients are pushing 8K reqs, hence maximizing 
NFS [rw]size, iozone is reporting sequential writes at ca. 8500 kB/s, 
which is pretty good for a 100Mbps link (right?).

IOW, the clients look and feel happy -- their numbers are largely 
pretty good -- but the server-side numbers are much lower.

That sounds bizzare to me. What am I missing?

--Paul Heinlein <heinlein@cse.ogi.edu>




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
