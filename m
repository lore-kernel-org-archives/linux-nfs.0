From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Re: nfsstat printing overflow
Date: Mon, 2 Jun 2003 00:10:45 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030602071045.GA16115@greglaptop.greghome.keyresearch.com>
References: <20030529232654.GA32598@doubt> <16086.61284.133472.312148@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-29-238.client.attbi.com ([12.234.29.238] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19MjSa-0004c6-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jun 2003 00:10:24 -0700
Received: from localhost.localdomain (greglaptop [127.0.0.1])
	by localhost.localdomain (8.12.8/8.12.5) with ESMTP id h527AkPW016130
	for <nfs@lists.sourceforge.net>; Mon, 2 Jun 2003 00:10:46 -0700
Received: (from lindahl@localhost)
	by localhost.localdomain (8.12.8/8.12.8/Submit) id h527Aj63016128
	for nfs@lists.sourceforge.net; Mon, 2 Jun 2003 00:10:45 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <16086.61284.133472.312148@notabene.cse.unsw.edu.au>
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

On Fri, May 30, 2003 at 03:43:00PM +1000, Neil Brown wrote:
> On Thursday May 29, grif@michaelgriffith.com wrote:
> > A small patch to handle when the RPC call counts are > 2^32/100.
> > 
> Thanks.
> However:
> 
> > +        unsigned long long      pct;
> 
> > +		for (j = 0; j < 6 && i + j < nr; j++) {
> > +                        pct = ((unsigned long long) info[i+j]*100)/total;
> > +                        printf("%-6d %2d%% ", info[i+j], pct);
> > +                }

It feels like overkill to use long long for this when you can get
just as good of behavior with:

	unsigned long toto100;

	if (total >= 100)
	   toto100 = total / 100;
	else
	   toto100 = 1;

	for (j = 0; j < 6 && i + j < nr; j++)
              printf("%-6d %2d%% ", info[i+j], info[i+j]/toto100);

In both pieces of code, if total overflows you get the wrong answer. So you
didn't get much of a benefit from the long long.

If you care about getting the %s reasonable when total is small, you can
move the if() inside the for().

Doesn't gcc inline code on archs without real 64-bit ops? Yech.

greg



-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
