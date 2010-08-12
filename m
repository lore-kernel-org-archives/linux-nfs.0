From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 9 (nfs)
Date: Thu, 12 Aug 2010 10:36:54 -0700
Message-ID: <4C643136.5090808@oracle.com>
References: <20100809132314.789e13f3.sfr@canb.auug.org.au>	 <20100809100856.b03a9bc1.randy.dunlap@oracle.com>	 <20100812091842.6a3b84b9.randy.dunlap@oracle.com> <1281634268.14329.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1281634268.14329.18.camel@heimdal.trondhjem.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/12/10 10:31, Trond Myklebust wrote:
> On Thu, 2010-08-12 at 09:18 -0700, Randy Dunlap wrote:
>> On Mon, 9 Aug 2010 10:08:56 -0700 Randy Dunlap wrote:
>>
>> ping??
> 
> Hi Randy,
> 
> I'm sorry. A heavy travel schedule is affecting my response time at the
> moment. I'll try to take care of this by Tuesday (when I get back home)
> if not before.

No problem.  Just wanted to make sure that it's not lost.

Thanks.


> Cheers
>   Trond
> 
>>> On Mon, 9 Aug 2010 13:23:14 +1000 Stephen Rothwell wrote:
>>>
>>>> Hi all,
>>>>
>>>> As the merge window is open, please do not add 2.6.37 material to your
>>>> linux-next included trees until after 2.6.36-rc1.
>>>>
>>>> Changes since 20100807:
>>>
>>>
>>> ERROR: "svc_gss_principal" [fs/nfs/nfs.ko] undefined!
>>>
>>>
>>> because in fs/nfs/Kconfig, NFS_V4 selects RPCSEC_GSS_KRB5
>>> and/or in fs/nfsd/Kconfig, NFSD_V4 selects RPCSEC_GSS_KRB5.
>>>
>>> RPCSEC_GSS_KRB5 does 5 selects, but none of these is enforced/followed
>>> by the fs/nfs[d]/Kconfig configs:
>>>
>>> 	select SUNRPC_GSS
>>> 	select CRYPTO
>>> 	select CRYPTO_MD5
>>> 	select CRYPTO_DES
>>> 	select CRYPTO_CBC
>>>
>>>
>>> Failing config is attached.
>>> ---
>>
>>
>> ---
>> ~Randy
>> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
