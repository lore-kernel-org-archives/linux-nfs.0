From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Wed, 21 Nov 2007 22:36:23 +0200
Message-ID: <D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
	<1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
	<1195650851.6039.425.camel@hurina>
	<1195653389.8374.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: multipart/mixed; boundary="===============1434126975=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuwIO-0007q3-ET
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:35:40 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuwIS-0001Im-W5
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:35:46 -0800
In-Reply-To: <1195653389.8374.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1434126975==
Content-Type: multipart/signed; protocol="application/pgp-signature";
	micalg=pgp-sha1; boundary="Apple-Mail-27-474335846"
Content-Transfer-Encoding: 7bit

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-27-474335846
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

On 21.11.2007, at 15.56, Trond Myklebust wrote:

> On Wed, 2007-11-21 at 15:14 +0200, Timo Sirainen wrote:
>
>> Now that I think of it, I guess the reason is that my 2.6.22 setup  
>> has
>> Linux+ext3 as NFS server and 2.6.17-rc2 setup has NetApp as  
>> server. So
>> even though open()+close() flushes the directory's attribute  
>> cache, it
>> doesn't flush the file name -> NFS handle cache unless mtime changes?
>
> Right. You're hitting the principal limitation of ext3 as an NFS  
> backend
> filesystem.
> As I said in an earlier mail, the resolution on the time is 1  
> second, so
> client 2 can basically not see any changes that happen within < 1  
> second
> on client 1. The reason is that the mtime stays the same.

With files it's possible to work around this limitation with fcntl  
locking, but directories can't be locked. So back to my original  
question: Would it be possible to have chmod(dir, (uid_t)-1,  
(gid_t)-1) flush its cache? I don't see what harm there could be in  
this, since normally no-one would do it anyway and the change is simple.


--Apple-Mail-27-474335846
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (Darwin)

iD8DBQFHRJbMyUhSUUBViskRAi8bAKCjhS5bJFChi7g1ZSv82/IpI/suWwCeJv+x
gmvHQoS783J5VYipiQTq2Yg=
=LRhE
-----END PGP SIGNATURE-----

--Apple-Mail-27-474335846--


--===============1434126975==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1434126975==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1434126975==--


