Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:49484 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757084Ab3EFUfl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 16:35:41 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv3: match sec= flavor against server list
Date: Mon, 6 May 2013 20:35:40 +0000
Message-ID: <9BC67816-C04D-4886-8C13-0820A16298D3@netapp.com>
References: <1367869268-3741-1-git-send-email-dros@netapp.com>
 <1367869418.9004.47.camel@leira.trondhjem.org>
In-Reply-To: <1367869418.9004.47.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 6, 2013, at 3:43 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-05-06 at 15:41 -0400, Weston Andros Adamson wrote:
>> Older linux clients match the 'sec=' mount option flavor against the server's
>> flavor list (if available) and return EPERM if the specified flavor or AUTH_NULL
>> (which "matches" any flavor) is not found.
>> 
>> Recent changes skip this step and allow the vfs mount even though no operations
>> will succeed, creating a 'dud' mount.
>> 
>> This patch reverts back to the old behavior of matching specified flavors
>> against the server list and also returns EPERM when no sec= is specified and
>> none of the flavors returned by the server are supported by the client.
>> 
>> Example of behavior change:
>> 
>> the server's /etc/exports:
>> 
>> /export/krb5      *(sec=krb5,rw,no_root_squash)
>> 
>> old client behavior:
>> 
>> $ uname -a
>> Linux one.apikia.fake 3.8.8-202.fc18.x86_64 #1 SMP Wed Apr 17 23:25:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>> mount.nfs: timeout set for Sun May  5 17:32:04 2013
>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>> mount.nfs: mount(2): Permission denied
>> mount.nfs: access denied by server while mounting zero:/export/krb5
>> 
>> recently changed behavior:
>> 
>> $ uname -a
>> Linux one.apikia.fake 3.9.0-testing+ #2 SMP Fri May 3 20:29:32 EDT 2013 x86_64 x86_64 x86_64 GNU/Linux
>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>> mount.nfs: timeout set for Sun May  5 17:37:17 2013
>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>> $ ls /mnt
>> ls: cannot open directory /mnt: Permission denied
>> $ sudo ls /mnt
>> ls: cannot open directory /mnt: Permission denied
>> $ sudo df /mnt
>> df: ‘/mnt’: Permission denied
>> df: no file systems processed
>> $ sudo umount /mnt
>> $
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> 
>> Version 2:
>> - now just uses specified flavor when:
>>   - AUTH_NULL is in the server list
>>   - flavor is in the server list
>> 
>> - now returns EPERM when no sec= specified and no client supported flavors are
>>   in the server list
>> 
> 
> Shouldn't that be EACCES?

Yes. I think both cases should be EACCES.

Will test and repost

-dros

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

