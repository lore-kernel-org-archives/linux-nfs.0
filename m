From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] TCP nfsd connection hangs when partial record header is
 received
Date: Tue, 13 May 2003 15:17:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16064.32759.745915.143947@notabene.cse.unsw.edu.au>
References: <Pine.A41.4.44.0305120927550.24170-100000@forte.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: olof@austin.ibm.com
In-Reply-To: message from olof@austin.ibm.com on Monday May 12
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

On Monday May 12, olof@austin.ibm.com wrote:
> Below patch resolves a hang where a TCP nfsd connection will hang even
> though new data is received on the socket. We've seen this a few times in
> our lab, but it usually happened every few weeks.
> 
> If a short record header is received, the SK_BUSY flag is never cleared,
> and even though new data arrives, it will not be handled. This in turn
> leads to hangs of particular clients (while others will continue to work
> without problem).
> 
> I also changed the return code for that condition to be the same as for a
> (regular) short read.
> 
> Patch is against 2.4.20.

Thanks.  It is needed for 2.5 as well.
I have added it to my patch collections for each and they should get
to Marcelo/Linus eventually.

NeilBrown


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
