Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cirse-out.extra.cea.fr ([132.167.192.142]:34619 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab2KMIyg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Nov 2012 03:54:36 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id qAD7sTNf031661
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Nov 2012 08:54:30 +0100
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id qAD7sTEf012174
	for <linux-nfs@vger.kernel.org>; Tue, 13 Nov 2012 08:54:29 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.cdc.esteban.ctsi (out.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id qAD7sTEf004833
	for <linux-nfs@vger.kernel.org>; Tue, 13 Nov 2012 08:54:29 +0100
Message-ID: <50A1FCB2.9090502@cea.fr>
Date: Tue, 13 Nov 2012 08:54:26 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tomasz Chmielewski <mangoo@wpkg.org>, linux-nfs@vger.kernel.org
Subject: Re: xattr support in NFS?
References: <939474821.100.1352749795732.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <939474821.100.1352749795732.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few years ago, SGI tried to promote "NFS3 XATTR", an extension to 
NFSv3 to add xattr support. It roughly added 3 functions to the protocol 
(GETXATTR, SETXATTR, LISTXATTR), in a similar way as what 9p.2000L does. 
Nothing but IRIX had this NFSv3 feature. As far as I know, it remained 
quite exotic and stayed a SGI's thing.

    Philippe

Matt W. Benjamin a écrit :
> Can you restate reasoning why it will never do so, and whether this is the same as saying it will never implement named attributes?
>
> Thanks,
>
> Matt
>
> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
>
>   
>> No. We will never support xattrs over NFS.
>>
>>     
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>> owner@vger.kernel.org] On Behalf Of Tomasz Chmielewski
>>> Sent: Monday, November 12, 2012 10:14 AM
>>> To: linux-nfs@vger.kernel.org
>>> Subject: xattr support in NFS?
>>>
>>> Does Linux support xattr in NFS?
>>>
>>> IF tries using it in both NFS3 and NFS4 under Debian Lenny (2.6.32,
>>>       
>> both
>>     
>>> server and client), without success.
>>>
>>> # setfattr -n user.comment -v "this is a comment" /mnt/nfs
>>> setfattr: /mnt/nfs: Operation not supported
>>>
>>>
>>> --
>>> Tomasz Chmielewski
>>> http://blog.wpkg.org
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>       
>> in the
>>     
>>> body of a message to majordomo@vger.kernel.org More majordomo info
>>>       
>> at
>>     
>>> http://vger.kernel.org/majordomo-info.html
>>>       
>> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�
>>     
>
>   

