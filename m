From: Matthew Wilcox <willy@debian.org>
Subject: Re: nfsd not working in 2.6.0-test4 on ia64
Date: Fri, 5 Sep 2003 12:53:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030905115312.GH18654@parcelfarce.linux.theplanet.co.uk>
References: <20030903220709.GJ18654@parcelfarce.linux.theplanet.co.uk> <16216.2231.419902.317479@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vF9R-0004c8-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 04:53:17 -0700
Received: from parcelfarce.linux.theplanet.co.uk
	([195.92.249.252] helo=www.linux.org.uk ident=93)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.22)
	id 19vF9P-0005G3-O6
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 04:53:16 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16216.2231.419902.317479@gargle.gargle.HOWL>
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

On Fri, Sep 05, 2003 at 01:53:27PM +1000, Neil Brown wrote:
> Very helpful details.  
> It looks like a simple case of 32-bit parochialism :-)
> 
> Does this patch help?

Nope.  Applied patch, rebooted with it, here's the full details again
(don't think anything changed, but just in case):

Sep  5 07:52:06 rowlf kernel: svc: socket e00000404404a680(inet e000004043d22480
), count=112, busy=0
Sep  5 07:52:06 rowlf kernel: svc: socket e000004043d22480 served by daemon e000
0040ea866900
Sep  5 07:52:06 rowlf kernel: svc: server e0000040ea866900, socket e00000404404a
680, inuse=1
Sep  5 07:52:06 rowlf kernel: svc: socket e000004043d22480 served by daemon e000
0040ea867500
Sep  5 07:52:06 rowlf kernel: svc: got len=104
Sep  5 07:52:06 rowlf kernel: svc: svc_authenticate (1)
Sep  5 07:52:06 rowlf kernel: svc: socket e000004043d22480 busy, not enqueued
Sep  5 07:52:06 rowlf kernel: svc: calling dispatcher
Sep  5 07:52:06 rowlf kernel: nfsd_dispatch: vers 2 proc 1
Sep  5 07:52:06 rowlf kernel: nfsd: GETATTR  32: 00000001 13000800 0002f9f8 0000
0000 00000000 00000000
Sep  5 07:52:06 rowlf kernel: nfsd: fh_verify(32: 00000001 13000800 0002f9f8 000
00000 00000000 00000000)
Sep  5 07:52:06 rowlf kernel: nfsd: storing reply in cache
Sep  5 07:52:06 rowlf kernel: svc: service e0000040ea866900, releasing skb e0000
040ff163d80
Sep  5 07:52:06 rowlf kernel: svc: socket e00000404404a680 sendto([e0000040ea30c
000 96... ], 96) = 0 (addr 2501a8c0)
Sep  5 07:52:06 rowlf kernel: svc: socket e000004043d22480 busy, not enqueued
Sep  5 07:52:06 rowlf kernel: svc: server e0000040ea866900 waiting for data (to 
= 3686400)
Sep  5 07:52:06 rowlf kernel: svc: server e0000040ea867500, socket e00000404404a
680, inuse=1
Sep  5 07:52:06 rowlf kernel: svc: got len=-11
Sep  5 07:52:06 rowlf kernel: svc: server e0000040ea867500 waiting for data (to 
= 3686400)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
