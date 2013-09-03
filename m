Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:42180 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755975Ab3ICTpR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 15:45:17 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: use the mach cred for SECINFO w/ integrity
Date: Tue, 3 Sep 2013 19:45:16 +0000
Message-ID: <943167B5-F14A-4DDB-9C18-FB3C095A696E@netapp.com>
References: <1378235929-4710-1-git-send-email-dros@netapp.com>
 <1378236327.6410.38.camel@leira.trondhjem.org>
 <5C9B2128-9A64-4231-8FF3-BEDDCB2C733D@netapp.com>
 <1378237184.6410.42.camel@leira.trondhjem.org>
In-Reply-To: <1378237184.6410.42.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2013, at 3:39 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-09-03 at 19:30 +0000, Adamson, Dros wrote:
>> On Sep 3, 2013, at 3:25 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>> wrote:
>> 
>>> On Tue, 2013-09-03 at 15:18 -0400, Weston Andros Adamson wrote:
>>>> Commit 5ec16a8500d339b0e7a0cc76b785d18daad354d4 introduced a regression
>>>> that causes SECINFO to fail without actualy sending an RPC if:
>>>> 
>>>> 1) the nfs_client's rpc_client was using KRB5i/p (now tried by default)
>>>> 2) the current user doesn't have valid kerberos credentials
>>>> 
>>>> This situation is quite common - as of now a sec=sys mount would use
>>>> krb5i for the nfs_client's rpc_client and a user would hardly be faulted
>>>> for not having run kinit.
>>>> 
>>>> The solution is to use the machine cred when trying to use an integrity
>>>> protected auth flavor for SECINFO.
>>>> 
>>>> Older servers may not support using the machine cred or an integrity
>>>> protected auth flavor for SECINFO in every circumstance, so we fall back
>>>> to using the user's cred and the filesystem's auth flavor in this case.
>>>> 
>>>> We run into another problem when running against linux nfs servers -
>>>> they return NFS4ERR_WRONGSEC when using integrity auth flavor (unless the
>>>> mount is also that flavor) even though that is not a valid error for
>>>> SECINFO*.  Even though it's against spec, handle WRONGSEC errors on SECINFO
>>>> by falling back to using the user cred and the filesystem's auth flavor.
>>>> 
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>> 
>>> Thanks! Applied…
>> 
>> Oh, sorry, I was hoping to foster more discussion around Chuck's comments to the nfsd side of this effort before adding this, although it's better than the state the client was in since 5ec16a8500d339b0e7a0cc76b785d18daad354d4.  Should I post the similar patches for SECINFO_NONAME and LAYOUTGET?
>> 
>> Specifically, Chuck's (very valid) point is what error should a server return to SECINFO using krb5i if it doesn't support that auth flavor?   
>> NFS4ERR_ACCESS looks like the best available option to me -- should I take this to the IETF list?
> 
> If the server doesn't support krb5i, then it won't even be able to
> receive our RPC call, so it can at best reply with an AUTH_BADCRED rpc
> level error, which rpc_verify_header() will translate as EACCES.

I'm sorry, I mean if the server supports krb5i, but not for SECINFO.  If the server doesn't support krb5i or there is a misconfiguration / time skew /etc, the client won't be using krb5i for the nfs_client's rpc_client and we'll never attempt to use it for SECINFO.

-dros

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

