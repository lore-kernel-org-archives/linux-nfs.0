From: Paul Libert <Paul.Libert@naturalsciences.be>
Subject: Re: kernel nlockmgr not registred with port mapper
Date: Wed, 18 Aug 2004 11:40:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41232421.6050303@naturalsciences.be>
References: <411C91BA.10506@naturalsciences.be> <1092413690.5046.20.camel@lade.trondhjem.org> <20040813163223.GA10834@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE1D5A272CB113EE8C935B51B"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxMwi-0002Mf-Sv
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 02:41:28 -0700
Received: from nestor.kbinirsnb.be ([193.190.234.10])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BxMwi-00009E-8V
	for nfs@lists.sourceforge.net; Wed, 18 Aug 2004 02:41:28 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040813163223.GA10834@suse.de>
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

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE1D5A272CB113EE8C935B51B
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Olaf Kirch wrote:

> On Fri, Aug 13, 2004 at 12:14:51PM -0400, Trond Myklebust wrote:
> 
>>Looks to me as if you are using the user space NFS server. That never
>>had any support for the NLM locking protocol. In fact IIRC the addition
>>of locking support was one of the main motivations at the time for
>>writing the kernel NFS server (correct me if I'm wrong there Olaf).
> 
> 
> That's right. Doing lockd in user space is horrible.
> 
> Olaf

Got it !

Switching to kernel-space server solved my problem !

Thanks for the help.

Regards.

Paul

--------------enigE1D5A272CB113EE8C935B51B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1-nr1 (Windows XP)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBIyQn9IdyKWFcSoYRAhluAJ9qV0BlxpRe4cF2iwvaKKtyKzol6gCgxnaP
Dir629BVt2+yI5wxKLEjqcY=
=kMVR
-----END PGP SIGNATURE-----

--------------enigE1D5A272CB113EE8C935B51B--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
