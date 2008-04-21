From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] NFS limits?
Date: Mon, 21 Apr 2008 17:21:21 -0400
Message-ID: <5B2B24EE-D67E-49EF-B9A1-6585EF7CF83A@oracle.com>
References: <480C8DAB.40504@cesca.es>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Jordi Prats <jprats-KO9VOOLprG0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53094 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbYDUVVa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 17:21:30 -0400
In-Reply-To: <480C8DAB.40504-KO9VOOLprG0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jordi-

On Apr 21, 2008, at 8:50 AM, Jordi Prats wrote:
> Hi all,
> I've a 4246 GB (above 4TB) using NFSv2 to export it. Some application
> are generating estrange errors, so it's possible I'm facing a NFS =20
> limit?
> How large can a be to be exported without problems?
>
> I'm using a 32bits architecture.

You need NFSv3, at least.  NFSv2 has various 2GiB limitations.

> --=20
> .....................................................................=
=2E
>         __
>        / /          Jordi Prats
>  C E / S / C A      Dept. de Sistemes
>      /_/            Centre de Supercomputaci=F3 de Catalunya
>
>  Gran Capit=E0, 2-4 (Edifici Nexus) =B7 08034 Barcelona
>  T. 93 205 6464 =B7 F.  93 205 6979 =B7 jprats-KO9VOOLprG0@public.gmane.org
> .....................................................................=
=2E
>
>
> ---------------------------------------------------------------------=
----
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference
> Don't miss this year's exciting event. There's still time to save =20
> $100.
> Use priority code J8TL2D2.
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.co=
m/javaone
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
=20
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



