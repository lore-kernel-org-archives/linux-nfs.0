From: Paul Libert <Paul.Libert@naturalsciences.be>
Subject: Re: kernel nlockmgr not registred with port mapper
Date: Fri, 13 Aug 2004 13:11:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411CA1CA.8040500@naturalsciences.be>
References: <411C91BA.10506@naturalsciences.be> <20040813104412.GY3516@hyperion.jason.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig102D40B9687D877E8613317C"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvZy3-0008VB-0U
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 04:11:27 -0700
Received: from nestor.kbinirsnb.be ([193.190.234.10])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BvZy1-0006RT-Q3
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 04:11:26 -0700
To: Gerhard den Hollander <gdenhollander@fugro-jason.com>
In-Reply-To: <20040813104412.GY3516@hyperion.jason.nl>
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
--------------enig102D40B9687D877E8613317C
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Gerhard,

All of the three machines are running NFSServer and are 'exports'ing 
filesystems.

Paul

Gerhard den Hollander wrote:

> * Paul Libert <Paul.Libert@naturalsciences.be> (Fri, Aug 13, 2004 at 12:02:34PM +0200)
> 
>>Dear List,
>>
>>Solution to this problem should be easy but I'm to blind to find out so 
>>  ...
>>
>>I'm having problem with to acquire locks on file over a nfs mounted 
>>filesystem.
> 
> 
> make sure both machines are running an nfsserver, and make sure both
> machines are exporting a file system
> (yes, indeed, the *client* must be running an NFServer and MUST be
> exporting a filesystem as well.
> 
> Currently listening to: ph2004-08-09d103
> 
> 	Gerhard,  (faliquid@xs4all.nl)	== The Acoustic Motorbiker == 	


--------------enig102D40B9687D877E8613317C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1-nr1 (Windows XP)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBHKHS9IdyKWFcSoYRAg33AJ4/MzkBLlPoas6UMjTv9tgf9iAi/ACfZPVZ
UB2z2fvjnyH91Z/dmab/6Ek=
=D4VK
-----END PGP SIGNATURE-----

--------------enig102D40B9687D877E8613317C--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
