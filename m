From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: Full IPv6 client and server support (kernel and user commands)
Date: Fri, 21 Nov 2008 13:55:44 +0100
Message-ID: <4926AFD0.6050202@bull.net>
References: <48D39CDE.1040600@bull.net> <48DA228D.9040302@linux.vnet.ibm.com>	<C0657B95-8B13-4D0B-A1D5-B1CDDB1C4AA7@oracle.com>	<48DB4C1C.6000805@bull.net> <48DB5D89.6000407@linux.vnet.ibm.com>	<48DB79A7.2080501@bull.net> <48DB7C51.8000606@linux.vnet.ibm.com>	<54717A2D-9C8B-48EB-AAEF-D6F5FF60E0D5@oracle.com>	<48DC824F.6070701@linux.vnet.ibm.com> <48DC90BD.4070702@bull.net>	<48DCB184.1030406@linux.vnet.ibm.com>	<8B169994-A636-440A-AF7A-7E043D18385E@oracle.com>	<48DDA945.7020800@linux.vnet.ibm.com> <48E06DAC.2030708@linux.vnet.ibm.com> <48E085A7.7040000@bull.net> <48E19A2E.7090005@linux.vnet.ibm.com> <48E62607.80809@bull.net> <48F31FEF.4040907@linux.vnet.ibm.com> <48F347B8.3010201@bull.net> <49269AB3.3020106@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Frank S Filz <ffilz@us.ibm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:51855 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbYKUMzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2008 07:55:55 -0500
In-Reply-To: <49269AB3.3020106-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


OK. I'll have a look.

Best Regards


Steve Dickson a =E9crit :

>Le Rouzic wrote:
> =20
>
>>  Hi,
>>  My patches are based on Chuck 's ones for nfs-utils and kernel. So
>>when those from Chuck
>>  are committed I will need to review mines if always OK.
>>  Steve Dickson is planning to integrate most of the mount and statd
>>command changes done by Chuck for IPV6
>>  in next package nfs-utils-1.1.4.
>>   =20
>>
>This is done and can be found in git://linux-nfs.org/nfs-utils git
>
>Also note number of IPv6 orientated changes have been added and
>will continue to be added  to both the libitrpc and rpcbind git=20
>trees found at:
>
>git://git.infradead.org/~steved/libtirpc.git
>git://git.infradead.org/~steved/rpcbind.git
>
>steved.
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" i=
n
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> =20
>


--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

