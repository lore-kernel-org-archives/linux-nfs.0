From: Christian Robottom Reis <kiko@async.com.br>
Subject: Potential skew in /proc/net/rpc/nfsd
Date: Wed, 19 Oct 2005 22:16:30 -0200
Message-ID: <20051020001630.GL30673@anthem.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


(Linux anthem 2.6.10-5-686-smp #1 SMP (Ubuntu Hoary))

Hello there,

    I've been studying the nfsd statistics file on our server, a
dual-hyperthreaded-Xeon box (which appears to 2.6 as having 4 CPUs) and
I've noticed an oddits in the thread statistics. Here's the output,
edited to display clearly what I mean:

            th
             8
       2747936
         59079.566
         14835.486
          5952.540
             0.000
          3293.329
          2232.819
          1900.259
          1999.936
             0.000
          6549.737

Do the values of zero in the 4th and 9th percentage there make any
sense, or are they an artifact of how the statistics are calculated
(noting that I have 8 threads being used)? I've shifted the number of
threads to 64 this morning, and this afternoon I now see:

            th
            64
       2748083
         59543.017
         14912.958
          5959.034
             0.854
          3293.654
          2233.022
          1900.395
          1999.936
             0.000
          6549.737

The 0.854 there in the 4th percentage suggests to me that the accounting
is now functioning as it should; I might be mistaken, since it's the
first time I look at these numbers, but that's what it suggests to me.

Take care,
--
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
