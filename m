From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench
	2.0
Date: Sat, 2 Nov 2002 22:19:56 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15812.16764.886879.463631@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D5503C@black.eng.netapp.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Andrew Ryan <andrewr@nam-shub.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1885gl-0000g1-00
	for <nfs@lists.sourceforge.net>; Sat, 02 Nov 2002 13:20:15 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5503C@black.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > call_start changes the way RPCs are counted, not how
     > retransmits are counted.

Wrong. It fixes the following bug too:

@@ -645,7 +663,6 @@
        case -ENOMEM:
        case -EAGAIN:
                task->tk_action = call_transmit;
-               clnt->cl_stats->rpcretrans++;
                break;
        default:
                if (clnt->cl_chatty)


Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
