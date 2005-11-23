From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Wed, 23 Nov 2005 04:31:14 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E2013327DF@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "David Miller" <davem@davemloft.net>, <neilb@cse.unsw.edu.au>,
	<trond.myklebust@fys.uio.no>, <linux-kernel@vger.kernel.org>,
	<nfs@lists.sourceforge.net>, <netdev@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eetmk-0004Ef-5F
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 04:31:38 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eetmh-0005OB-TD
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 04:31:38 -0800
To: "Adrian Bunk" <bunk@stusta.de>
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

> On Thu, Oct 06, 2005 at 07:13:14AM -0700, Lever, Charles wrote:
>=20
> > actually, can we hold off on this change?  the RPC=20
> transport switch will
> > eventually need most of those EXPORT_SYMBOLs.
>=20
> Am I right to assume this will happen in the foreseeable future?

the first portion of the transport switch is in 2.6.15-rcX.  at this
point i'm expecting the EXPORT_SYMBOL changes to go in 2.6.17 or later.

so i don't remember why you are removing xdr_decode_string.  are we sure
that no-one will need this functionality in the future?  it is harmless
to remove today, but i wonder if someone is just going to add it back
sometime.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
