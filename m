From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: svc_create_xprt for nfsd and lockd with ipv6
Date: Wed, 28 May 2008 16:56:28 +0200
Message-ID: <483D729C.307@bull.net>
References: <483A874A.5080502@bull.net>
	<DDB646D2-C5B3-4EC3-A8DB-EF7B6F99A8E2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: linux-nfs@vger.kernel.org, nfsv4 <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <DDB646D2-C5B3-4EC3-A8DB-EF7B6F99A8E2@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever a =E9crit :

> On May 26, 2008, at 5:47 AM, Le Rouzic wrote:
>
>> Hi,
>> I was thinking that linux-2.6.25-rc6-CITI_NFS4_ALL-1 nfsd was able  =

>> to listen on the IPV6 domain also.
>> Since 2.6.24 Main changes have been done to replace the way to make  =

>> a socket for nfsd and lockd by replacing
>> svc_makesock routine by the *svc_create_xprt* service.
>>
>> Does anybody know if there is already a patch on this new code to  =

>> support IPV6 for nfsd and lockd ?
>
>
> See:
>
>    http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>
> There are patches that adjust svc_create_xprt() appropriately to take  =

> an address family argument.

   OK . I try them.
   Thanks

>
> -- =

> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> -- =

> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
