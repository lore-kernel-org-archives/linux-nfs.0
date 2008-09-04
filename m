From: =?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?= <francois.valenduc@skynet.be>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 04 Sep 2008 19:41:17 +0200
Message-ID: <48C01DBD.7000309@skynet.be>
References: <48BED539.1000404@skynet.be> <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com> <48C0108F.40204@skynet.be> <20080904165645.GG4536@fieldses.org> <48C01B5F.3060808@skynet.be> <20080904173346.GJ4536@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:53516 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYIDRlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 13:41:25 -0400
In-Reply-To: <20080904173346.GJ4536@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields a =C3=A9crit :
> On Thu, Sep 04, 2008 at 07:31:11PM +0200, Fran=C3=A7ois Valenduc wrot=
e:
>  =20
>> I had indeed forgot to add sec=3Dkrb5 to the export options. But eve=
n if I =20
>> add it, it doesn't change anything.
>>    =20
>
> OK, and you re-exported?  (Just to double-check--what does exportfs -=
v
> say?)
>
>  =20
>> Is it really possible to use krb5  authentification with nfs ? I hav=
e
>> read a lot of howto and follow the  instructions and it never
>> succeeds...
>>    =20
>
> I'm sorry you've had trouble with it, but yes, it definitely works--I
> use it every day.
>
> --b.
>
>  =20
So, here is the output of exportfs -v relating to my home folder:
/home/francois =20
ordi-francois(rw,wdelay,root_squash,no_subtree_check,sec=3Dkrb5,rw,root=
_squash,no_all_squash)

