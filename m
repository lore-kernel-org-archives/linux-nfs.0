From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SVC sockets don't disable Nagle
Date: 30 Apr 2003 14:45:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznm8duhs.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0304301356400.15733-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olof Johansson <olof@austin.ibm.com>,
	  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ar2n-0007ne-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 05:50:41 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0304301356400.15733-100000@kenzo.iwr.uni-heidelberg.de>
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

>>>>> " " == Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:

    >> In essence, this will result in some additional network
    >> overhead due to headers, but the response times will be
    >> perceived as faster even for slower networks.

     > True, until the network becomes too slow, then you see "server
     > not responding" messages...

Anybody trying to run multi-user NFS over a 9.6Kbaud link needs their
head examined.
For *real use* situations, the total number of on-the-wire NFS
requests is currently limited to 16. In addition, TCP timeouts are
supposed to be > 1 minute. The above scenario simply will not happen.

For any reasonable setup over a slow network, the aggregation will
happen naturally anyway since the NFS layer both can and will fill the
buffers as soon as they start to empty (provided we have pending
datagrams).

For fast networks, we should at least ensure that single datagrams are
aggregated properly. The way to do that is to use MSG_MORE...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
