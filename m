From: Andrew Ryan <andrewr@nam-shub.com>
Subject: RE: nfs performance: read only/gigE/nolock/1Tb per day
Date: Mon, 22 Apr 2002 09:23:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020422090930.02829b60@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: "'jason andrade'" <jason@dstc.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zgeJ-0005Iy-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 09:26:43 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

Using NFSv3/TCP (with Trond's patches!) is good advice, the performance is 
generally better from my tests, and if UDP is hanging on you, trying TCP 
can't seriously hurt. Note that with NFSv3/TCP, you may experience hangs 
under load as well, as I did, unless you use the latest 2.4.19-pre kernel 
with Trond's patches.

Jason, as to your earlier question about applying Trond's patches to RH 
kernels, the short answer is that yes, you can get them to apply (at least 
the last time I checked, which was the 2.4.9 RPM). But RH already includes 
some NFS patches, so you'd need to remove those and put in Trond's. You 
will need to be comfortable hacking up a RPM specfile and have some 
patience and diligence to get the resulting kernel RPM to build, however. 
And when you're done you won't have a strictly RH kernel, which won't be a 
problem unless you pay for technical support and expect to ever get it. But 
since RH seems to give very little attention to a stable, reliable NFS 
client implementation in their kernels, if you're stuck using NFS on linux, 
it may be your only choice.


andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
