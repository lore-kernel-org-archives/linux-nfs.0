From: "Quentin Fennessy" <quentin.fennessy@amd.com>
Subject: Re: 2.4.20-rc1 NFS/TCP client (still) hangs running
 dbench 2.0
Date: Sun, 03 Nov 2002 08:16:34 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <cs9n0oqbuwt.fsf@tesla.amd.com>
References: <0211011318080N.01583@stinkpad060501>
 <3DC2E7B6.6090400@collab.net> <0211011318080N.01583@stinkpad060501>
 <5.0.2.1.0.20021102211350.0291eec0@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from amdext2.amd.com ([163.181.251.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188LYX-0005Qe-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Nov 2002 06:16:49 -0800
To: "Andrew Ryan" <andrewr@nam-shub.com>
In-Reply-To: <5.0.2.1.0.20021102211350.0291eec0@pop.sfrn.dnai.com> (
 "Andrew Ryan"'s message of "Sat, 02 Nov 2002 21:21:02 -0800")
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

>>>>> Andrew Ryan writes:

 > At 10:58 PM 11/1/02 +0100, Trond Myklebust wrote:
 >> It is probably just the (known) accounting error in the 'retransmit'
 >> statistics. Try applying the patch
 >> 
 >> http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-01-call_start.dif
 >> 
 >> if it bothers you.

 > Yes, you are right, it seems the counter is broken, and performance is
 > fine. I did bonnie++ runs with 2.4.20rc1 kernels with and without the
 > call_start patch, and didn't see any significant difference.

 > But, it does bother me since I want to be able to diagnose network errors if
 > I ever have them, and with a busted counter it will be impossible to tell
 > what my real error rate is. Can the call_start patch go to Marcelo for
 > 2.4.20rc2?

I'm an end user with approximately 3000 Linux NFS clients.
I will really appreciate correct counters when I'm debugging
nfs server, client and network problems. I've had to ignore 
spurious counts of nfs retrans while debugging network issues.

I hope this patch will be in 2.4.20rc2. Thanks to all of you for
providing an excellent client-side implementation. And I am 
serious.

 > After a bonnie run with the call_start patch, I get this, which is much
 > better :)

 > $ nfsstat -c
 > Client rpc stats:
 > calls      retrans    authrefrsh
 > 1648050    0          0


-- 
Quentin Fennessy   		Quentin.Fennessy@amd.com	
				Office: 512.602.3873
				Cell:   512.694.7489




-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
