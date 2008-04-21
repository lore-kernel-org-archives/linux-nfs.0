From: Jordi Prats <jprats-KO9VOOLprG0@public.gmane.org>
Subject: Re: [NFS] NFS limits?
Date: Mon, 21 Apr 2008 16:21:00 +0200
Message-ID: <480CA2CC.80209@cesca.es>
References: <480C8DAB.40504@cesca.es> <480C9A1B.20604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34965 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756220AbYDUOYk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 10:24:40 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jnwwg-0005SZ-Gh
	for linux-nfs@vger.kernel.org; Tue, 22 Apr 2008 00:24:38 +1000
In-Reply-To: <480C9A1B.20604@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peter,
My boss is reluctant to upgrade this server, so I'm stuck to NFSv2 :( I=
=20
hope this will convince him !

Thanks,
Jordi

Peter Staubach wrote:
> Jordi Prats wrote:
>> Hi all,
>> I've a 4246 GB (above 4TB) using NFSv2 to export it. Some applicatio=
n=20
>> are generating estrange errors, so it's possible I'm facing a NFS=20
>> limit? How large can a be to be exported without problems?
>>
>> I'm using a 32bits architecture.
>>
>> Thanks!
>> Jordi
>>
>>  =20
> NFSv2 is a 32 bit file access protocol, so don't be surprised
> if you see EFBIG sorts of errors on operations such as FSSTAT.
>
> In particular, that file system size is too large to represent,
> I am sort of surprised that it would even be mountable.
>
> Why not use NFSv3 or NFSv4?
>
>       ps
>
>


--=20
=2E....................................................................=
=2E
         __
        / /          Jordi Prats
  C E / S / C A      Dept. de Sistemes
      /_/            Centre de Supercomputaci=F3 de Catalunya

  Gran Capit=E0, 2-4 (Edifici Nexus) =B7 08034 Barcelona
  T. 93 205 6464 =B7 F.  93 205 6979 =B7 jprats-KO9VOOLprG0@public.gmane.org
=2E....................................................................=
=2E=20


-----------------------------------------------------------------------=
--
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference=20
Don't miss this year's exciting event. There's still time to save $100.=
=20
Use priority code J8TL2D2.=20
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/=
javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

