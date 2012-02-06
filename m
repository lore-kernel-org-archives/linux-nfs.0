Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:55243 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755825Ab2BFSzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 13:55:24 -0500
Message-ID: <4F3021F2.6090607@steve-ss.com>
Date: Mon, 06 Feb 2012 19:54:42 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jim Rees <rees@umich.edu>, Liam Gretton <liam.gretton@leicester.ac.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2D9A0E.6010503@leicester.ac.uk> <4F2E4B50.5040701@steve-ss.com> <20120205141611.GA12826@umich.edu> <4F2EB471.9060508@leicester.ac.uk> <20120205173728.GA13418@umich.edu> <20120206163945.GA29579@fieldses.org>
In-Reply-To: <20120206163945.GA29579@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/12 17:39, J. Bruce Fields wrote:
> On Sun, Feb 05, 2012 at 12:37:28PM -0500, Jim Rees wrote:
>> Liam Gretton wrote:
>>
>>    On 05/02/2012 14:16, Jim Rees wrote:
>>    >There is a a NFS wiki, and it does have kerberos setup instructions:
>>    >http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
>>    >
>>    >The wiki has mostly been used by developers for developer info but it might
>>    >be a good thing to use it for more general info too.
>>
>>    Thanks, the problem isn't getting NFS with Kerberos to work in
>>    general, it's with AD as the KDC. It seems that NFS still only
>>    accepts DES encrypted Kerberos tickets, and these are specifically
>>    disabled in Windows Server 2008 R2.
>>
>> Wasn't that fixed recently?
> Yes, it supports some AES-based enctypes now, for example.  I wouldn't
> know a better source of the details than
>
> 	git log net/sunrpc/auth_gss/gss_krb5_*
>
> If someone wanted to summarize the situation for the wiki, go for it.
Hi
nfs with arcfour seems OK here with Samba 4. I don't think it's the 
default for AD but your windows admins may be happier with it. I think 
his is the relevant bit:

Kerberos: ENC-TS Pre-authentication succeeded -- HH3$@HH3.SITE using 
arcfour-hmac-md5
Kerberos: AS-REQ authtime: 2012-02-06T19:44:47 starttime: unset endtime: 
2012-02-07T05:44:47 renew till: 2012-02-07T19:44:47
Kerberos: Client supported enctypes: aes256-cts-hmac-sha1-96, 
aes128-cts-hmac-sha1-96, des3-cbc-sha1, arcfour-hmac-md5, des-cbc-crc, 
des-cbc-md5, des-cbc-md4, using arcfour-hmac-md5/arcfour-hmac-md5
Kerberos: Requested flags: renewable-ok
Kerberos: TGS-REQ HH3$@HH3.SITE from ipv4:192.168.1.3:45421 for 
nfs/hh3.hh3.site@HH3.SITE [canonicalize, renewable]
Kerberos: TGS-REQ authtime: 2012-02-06T19:44:47 starttime: 
2012-02-06T19:44:47 endtime: 2012-02-07T05:44:47 renew till: 20

HTH
Steve
