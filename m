From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss
	server cases
Date: Mon, 4 Feb 2008 17:15:21 -0500
Message-ID: <20080204221521.GH18682@fieldses.org>
References: <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com> <20080128214851.GO16785@fieldses.org> <E9EA25D0-1865-4EC2-BE61-8DA062C43C60@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kbuild@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <E9EA25D0-1865-4EC2-BE61-8DA062C43C60@oracle.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2008 at 04:29:40PM -0500, Chuck Lever wrote:
> On Jan 28, 2008, at 4:48 PM, J. Bruce Fields wrote:
>> On Mon, Jan 28, 2008 at 04:12:26PM -0500, Chuck Lever wrote:
>>> On Jan 28, 2008, at 1:28 PM, J. Bruce Fields wrote:
>>>> I don't care either way, but I'm inclined to leave this as is until
>>>> someone comes along with really clear and convincing criteria for  
>>>> when
>>>> to choose select and when to choose depends.
>>>
>>> If NFSv4 or GSS *require* procfs to work, then "depends" is the right
>>> choice.
>>
>> Neither CONFIG_NFS_FS nor CONFIG_NFSD_FS seem to be following this  
>> rule?
>
> After looking into this, I've found that there are a couple of reasons 
> for this.
>
> First, as I posted last week, "select" is usually OK for non-visible  
> CONFIG options, like LOCKD or SUNRPC.
>
> But, second, we have a mix of boolean and tristate variables here -- and 
> a boolean that selects another tristate variable can only choose Y or N 
> (not M).  So the "select ... if ..." clauses are placed up in  
> CONFIG_NFSD on purpose in order to allow the selected variables to be  
> set to M if CONFIG_NFSD is set to M.  See commit f05e15b5.

OK, so we only really need "select ... if ..." clauses in CONFIG_NFSD
when the thing we're selecting is a tristate.  But PROC_FS is a boolean.  

>
> I'm not inclined to adjust any of this for the moment.
>
> And, a quick grep around other Kconfig files reveals that no-one else  
> uses "select PROC_FS" -- every case uses "depends on".  Thus  
> CONFIG_NFSD_V4 should use "depends on PROC_FS" as well.

OK.  Is there a chance you make a patch with a changelog summarizing
this?

> Also, this  patch doesn't touch the client side -- should CONFIG_NFSV4
> depend on  PROC_FS too?

No, the server case is unique since it uses files under /proc for
certain upcalls necessary to support nfsv4 and rpcsec_gss.

> Since SUNRPC_GSS is already a non-visible config option and is set via 
> "select", it's more difficult to say with certainty how a "depends on 
> PROC_FS" clause should be constructed for that.  However, MAINTAINERS 
> suggests that linux-kbuild@vger might be an appropriate place to ask 
> about these things.

OK, so the question is: how can we ensure that PROC_FS is turned on when
SUNRPC_GSS *and* NFSD are (where both SUNRPC_GSS and NFSD may be
independently set on or off), while still leaving SUNRPC_GSS a tristate
whose value is at least that of RPCSEC_GSS_KRB5 and RPCSEC_GSS_SPKM3.

--b.
