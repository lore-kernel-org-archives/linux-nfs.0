Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-Id: <DDB646D2-C5B3-4EC3-A8DB-EF7B6F99A8E2@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Le Rouzic <aime.le-rouzic@bull.net>
In-Reply-To: <483A874A.5080502@bull.net>
Subject: Re: svc_create_xprt for nfsd and lockd with ipv6
Date: Tue, 27 May 2008 10:27:52 -0400
References: <483A874A.5080502@bull.net>
Cc: linux-nfs@vger.kernel.org, nfsv4 <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On May 26, 2008, at 5:47 AM, Le Rouzic wrote:
> Hi,
> I was thinking that linux-2.6.25-rc6-CITI_NFS4_ALL-1 nfsd was able  
> to listen on the IPV6 domain also.
> Since 2.6.24 Main changes have been done to replace the way to make  
> a socket for nfsd and lockd by replacing
> svc_makesock routine by the *svc_create_xprt* service.
>
> Does anybody know if there is already a patch on this new code to  
> support IPV6 for nfsd and lockd ?

See:

    http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary

There are patches that adjust svc_create_xprt() appropriately to take  
an address family argument.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
