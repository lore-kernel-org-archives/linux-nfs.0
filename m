From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: NFSv3/TCP client hangs under load (2.4.17+NFS_ALL)
Date: Sat, 13 Apr 2002 12:13:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020413120609.0288acc0@pop.sfrn.dnai.com>
References: <0204122022230I.01167@stinkpad060501>
 <0204122022230I.01167@stinkpad060501>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smithers.sfrn.dnai.com ([208.59.199.26])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wSxV-00059W-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Apr 2002 12:13:13 -0700
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

I will try this -- but it will take me a longer while to put a new kernel 
through all the necessary paces so I can use it in production, and I don't 
like to use pre* kernels in production. In the meantime, as a workaround, 
should UDP on 2.4.17+NFS_ALL be more robust? I'll try it anyway, but I'm 
looking for short term workarounds that will alleviate my problem without 
changing kernels or significantly impacting NFS client performance.

In the meantime, I've found even stranger manifestations of the hang. I 
have been able to create a case (randomly it seems) where every directory 
on the hung mount is accessible, except for one. Any process accessing this 
directory hangs. But I can access other directories on the same mount, and 
stat the mount just fine. Go figure.


andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
