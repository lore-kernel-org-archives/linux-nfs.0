From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 17:05:13 +0100
Message-ID: <491AFEB9.1090208@bull.net>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:57863 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbYKLQGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:06:35 -0500
In-Reply-To: <20081112133553.GA32294-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar H. Gunderson a =C3=A9crit :

>On Wed, Nov 12, 2008 at 01:00:27AM -0500, Chuck Lever wrote:
> =20
>
>>Keep an eye out for IPv6-related patches for nfs-utils.  The key is t=
o =20
>>ensure IPv4 continues to work, especially on Debian which tracks =20
>>upstream nfs-utils closely.
>>   =20
>>
>
>We don't plan to incorporate IPv6-specific patches before upstream doe=
s (and
>lenny, our upcoming release, is not going to get libtirpc or rpcbind).=
 When
>upstream nfs-utils is ready, you can expect us to configure with
>--enable-ipv6 pretty quickly, though :-)
>
>I still haven't had any success with nfsd on the server side in Linux;=
 it's a
>bit unclear to me what nfs-utils to use in particular.
>
>/* Steinar */
> =20
>
 Hi,
 There is a prototype nfs-utils package based on nfs-utils-1.1.2 you ca=
n=20
play with at http://nfsv4.bullopensource.org/

Regards

--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

