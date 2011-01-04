Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48635 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab1ADTVq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 14:21:46 -0500
Received: by ewy5 with SMTP id 5so6602916ewy.19
        for <linux-nfs@vger.kernel.org>; Tue, 04 Jan 2011 11:21:45 -0800 (PST)
In-Reply-To: <4D236F43.4040403@cora.nwra.com>
References: <4D23589B.6030409@cora.nwra.com>
	<AANLkTik3XOGSX_X4mRYWP4XA-j8t1DSn7JVrY6gZLaak@mail.gmail.com>
	<4D236F43.4040403@cora.nwra.com>
Date: Tue, 4 Jan 2011 14:18:56 -0500
Message-ID: <AANLkTi=cnUPwv7P4u71jyf3GoEAR6B3AeK+A5-KmJUgk@mail.gmail.com>
Subject: Re: Trouble mounting from EL5.5 server on Fedora 14 -
 gss_kerberos_mech: unsupported algorithm 6
From: Kevin Coffman <kwc@citi.umich.edu>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

That note is only relevant for NFS clients.  The NFS client takes
advantage of a Kerberos function to limit the enctypes negotiated with
the server.

The only way the KDC knows how to limit the enctypes negotiated for a
server is to limit the enctypes when creating its keytab.

K.C.

On Tue, Jan 4, 2011 at 2:04 PM, Orion Poplawski <orion@cora.nwra.com> wrote:
> On 01/04/2011 11:37 AM, Kevin Coffman wrote:
>>
>> On Tue, Jan 4, 2011 at 12:27 PM, Orion Poplawski<orion@cora.nwra.com>
>>  wrote:
>>>
>>> I'm trying to get kerberized NFSv4 setup for the first time (have had
>>> non-secure v4 up for a while).  Client is Fedora 14, server is CentOS
>>> 5.5.
>>>
>>> [ ... ]
>>>
>>> keytabs on server and client are like:
>>>
>>>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (Triple DES cbc mode with
>>> HMAC/sha1)
>>>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (ArcFour with HMAC/md5)
>>>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES with HMAC/sha1)
>>>   3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES cbc mode with RSA-MD5)
>>>
>>> Any ideas?
>>
>> Only DES is supported for your server's kernel:
>>
>> http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html
>
> Indeed, it does work if I limit the keys to DES only
> (des-hmac-sha1:normal,des-cbc-md5:normal).  Although I had seen at least one
> report that using ktadd -e des-cbc-crc:normal was no longer necessary as of
> 5.2:
>
> http://sadiquepp.blogspot.com/2009/02/how-to-configure-nfsv4-with-kerberos-in.html
>
> --
> Orion Poplawski
> Technical Manager                     303-415-9701 x222
> NWRA/CoRA Division                    FAX: 303-415-9702
> 3380 Mitchell Lane                  orion@cora.nwra.com
> Boulder, CO 80301              http://www.cora.nwra.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
