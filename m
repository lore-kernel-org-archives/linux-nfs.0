From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: NFSv3/TCP client hangs under load (2.4.17+NFS_ALL)
Date: Sun, 21 Apr 2002 12:01:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020421120019.0296c220@pop.sfrn.dnai.com>
References: <0204122022230I.01167@stinkpad060501>
 <0204122022230I.01167@stinkpad060501>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smithers.sfrn.dnai.com ([208.59.199.26])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zMa4-0002tz-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Apr 2002 12:01:00 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsads7fnfa.fsf@charged.uio.no>
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

At 08:44 PM 4/13/02 +0200, Trond Myklebust wrote:

>I'm actually in the process of rewriting this whole part of the TCP
>code. For 2.4.19-pre6, the code in the corresponding NFS_ALL patch
>should be more robust against interference (and possibly a bit faster
>than the old code). It would be nice if you could give it a go...


I tried the 2.4.19-pre7 kernel with your NFS patch with TCP , and it did 
not produce the hang under the same loading conditions. I didn't do 
performance testing between the two, if I do, I'll let you know if it's faster.

So, I guess the lesson here is to beware the NFSv3/TCP code in 2.4.17 under 
load, and use 2.4.19 when it is released, or use UDP.


thanks,
andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
