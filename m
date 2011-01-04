Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earth.cora.nwra.com ([65.44.101.180]:51495 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab1ADTEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 14:04:39 -0500
Message-ID: <4D236F43.4040403@cora.nwra.com>
Date: Tue, 04 Jan 2011 12:04:35 -0700
From: Orion Poplawski <orion@cora.nwra.com>
To: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: Trouble mounting from EL5.5 server on Fedora 14 - gss_kerberos_mech:
 unsupported algorithm 6
References: <4D23589B.6030409@cora.nwra.com> <AANLkTik3XOGSX_X4mRYWP4XA-j8t1DSn7JVrY6gZLaak@mail.gmail.com>
In-Reply-To: <AANLkTik3XOGSX_X4mRYWP4XA-j8t1DSn7JVrY6gZLaak@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/04/2011 11:37 AM, Kevin Coffman wrote:
> On Tue, Jan 4, 2011 at 12:27 PM, Orion Poplawski<orion@cora.nwra.com>  wrote:
>> I'm trying to get kerberized NFSv4 setup for the first time (have had
>> non-secure v4 up for a while).  Client is Fedora 14, server is CentOS 5.5.
>>
>> [ ... ]
>>
>> keytabs on server and client are like:
>>
>>    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (Triple DES cbc mode with
>> HMAC/sha1)
>>    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (ArcFour with HMAC/md5)
>>    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES with HMAC/sha1)
>>    3 nfs/orca.cora.nwra.com@CORA.NWRA.COM (DES cbc mode with RSA-MD5)
>>
>> Any ideas?
>
> Only DES is supported for your server's kernel:
>
> http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html

Indeed, it does work if I limit the keys to DES only 
(des-hmac-sha1:normal,des-cbc-md5:normal).  Although I had seen at least one 
report that using ktadd -e des-cbc-crc:normal was no longer necessary as of 5.2:

http://sadiquepp.blogspot.com/2009/02/how-to-configure-nfsv4-with-kerberos-in.html

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA/CoRA Division                    FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com
