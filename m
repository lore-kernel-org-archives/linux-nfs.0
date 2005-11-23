From: Neil Brown <neilb@suse.de>
Subject: Re: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Thu, 24 Nov 2005 10:07:13 +1100
Message-ID: <17284.63009.25299.139531@cse.unsw.edu.au>
References: <044B81DE141D7443BCE91E8F44B3C1E2013327DF@exsvl02.hq.netapp.com>
	<20051123162528.GL3963@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	David Miller <davem@davemloft.net>, trond.myklebust@fys.uio.no,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ef3i7-0004xc-2h
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 15:07:31 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ef3i6-0000FC-Fq
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 15:07:31 -0800
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: message from Adrian Bunk on Wednesday November 23
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

On Wednesday November 23, bunk@stusta.de wrote:
> On Wed, Nov 23, 2005 at 04:31:14AM -0800, Lever, Charles wrote:
> > so i don't remember why you are removing xdr_decode_string.  are we sure
> > that no-one will need this functionality in the future?  it is harmless
> > to remove today, but i wonder if someone is just going to add it back
> > sometime.
> 
> It's unused and you said:
>   the only harmless change i see below is removing xdr_decode_string().
> 

As 'xdr_decode_string' (sometimes) modifies the buffer that it is
decoding, I don't think it's usage should be encouraged.  If it is no
longer in use, then I fully support and encourage removing it.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
