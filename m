From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] remove redundant NULL pointer checks prior to calling kfree() in fs/nfsd/
Date: Sun, 27 Mar 2005 15:45:27 +0300
Message-ID: <200503271545.28335.vda@ilport.com.ua>
References: <Pine.LNX.4.62.0503252319220.2498@dragon.hyggekrogen.localhost> <Pine.LNX.4.61.0503251731240.6372@chaos.analogic.com> <1111826041.6293.31.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Cc: Jesper Juhl <juhl-lkml@dif.dk>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DFX9F-00083Y-4S
	for nfs@lists.sourceforge.net; Sun, 27 Mar 2005 04:45:45 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DFX9E-0005IZ-11
	for nfs@lists.sourceforge.net; Sun, 27 Mar 2005 04:45:44 -0800
To: Arjan van de Ven <arjan@infradead.org>, linux-os@analogic.com
In-Reply-To: <1111826041.6293.31.camel@laptopd505.fenrus.org>
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

On Saturday 26 March 2005 10:34, Arjan van de Ven wrote:
> On Fri, 2005-03-25 at 17:34 -0500, linux-os wrote:
> > On Fri, 25 Mar 2005, Jesper Juhl wrote:
> > 
> > > (please keep me on CC)
> > >
> > >
> > > checking for NULL before calling kfree() is redundant and needlessly
> > > enlarges the kernel image, let's get rid of those checks.
> > >
> > 
> > Hardly. ORing a value with itself and jumping on condition is
> > real cheap compared with pushing a value into the stack
> 
> which century are you from?
> "jumping on condition" can easily be 100+ cycles, depending on how
> effective the branch predictor is. Pushing a value onto the stack otoh
> is half a cycle.

linux-os is right because kfree does NULL check with exactly
the same code sequence, test and branch:

# objdump -d mm/slab.o
...
000012ef <kfree>:
    12ef:       55                      push   %ebp
    12f0:       89 e5                   mov    %esp,%ebp
    12f2:       57                      push   %edi
    12f3:       56                      push   %esi
    12f4:       53                      push   %ebx
    12f5:       51                      push   %ecx
    12f6:       8b 7d 08                mov    0x8(%ebp),%edi
    12f9:       85 ff                   test   %edi,%edi
    12fb:       74 46                   je     1343 <kfree+0x54>
...
...
...
    1343:       8d 65 f4                lea    0xfffffff4(%ebp),%esp
    1346:       5b                      pop    %ebx
    1347:       5e                      pop    %esi
    1348:       5f                      pop    %edi
    1349:       5d                      pop    %ebp
    134a:       c3                      ret

So kfree(p) indeed will spend time for doing a call,
for test-and-branch, *and* finally for ret,
while if(p) kfree(p) will do test-and-branch first
and won't do call/ret if p==NULL.

However, if p is not NULL, if(p) kfree(p) does:
1) test-and-branch (not taken)
2) call
3) another test-and-branch (not taken)!

I conclude that if(p) kfree(p) makes sense only if:
a) p is more often NULL than not, and
b) it's in the hot path (you don't want to save on code size)

Since (a) is not typical, I think Jesper's cleanups are ok.
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
