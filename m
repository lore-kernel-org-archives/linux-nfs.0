From: "Brandon D. Valentine" <brandon@dvalentine.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 21:13:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040829021326.GC84014@brandon.dvalentine.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com> <4130BC76.9070202@RedHat.com> <20040828183847.GA84014@brandon.dvalentine.com> <4131323C.6060509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1FED-0006Uf-Bt
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 19:15:33 -0700
Received: from mail.michaelchaney.com ([207.65.84.68] helo=daphne.michaelchaney.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C1FEC-0001Lz-NO
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 19:15:33 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4131323C.6060509@RedHat.com>
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

On Sat, Aug 28, 2004 at 09:32:44PM -0400, Steve Dickson wrote:
> Brandon D. Valentine wrote
> >In other words: what the heck are you talking about? =)
> > 
> I thought  the problem was that rpc.mount was being
> *unintentionally* started with the " -no-nfs-version  3"
> flag which I was  happening in my testing of the nfs4 code
> Something similar to:
> 
> root       395     1  0 Aug17 ?        00:00:00 /usr/sbin/rpc.mountd 
> --no-nfs-version 3
> 
> But I guess I was mistaken......

No problem.  Thanks for taking the the time to respond.

BTW, I noticed you've worked on the util-linux package some recently.
Can you look into whether the patch James Pearson posted in this thread
will make it into Fedora Core 3 Test 2?  It would be a shame for Fedora
Core 3 to be released with a /bin/mount that doesn't work with NFSv2
servers, especially when the fix is so small.

Thanks,

Brandon D. Valentine
-- 
brandon@dvalentine.com                           http://www.geekpunk.net
Pseudo-Random Googlism:  summer is boom time for building


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
