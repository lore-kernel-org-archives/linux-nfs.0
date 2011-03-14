Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59190 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab1CNTfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 15:35:14 -0400
Date: Mon, 14 Mar 2011 15:35:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, roel <roel.kluin@gmail.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110314193501.GE25442@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
 <20110309154230.66bc2c36.akpm@linux-foundation.org>
 <20110310180800.GA31984@fieldses.org>
 <4D799C6E.1050101@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D799C6E.1050101@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 11, 2011 at 11:52:14AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Wed, Mar 09, 2011 at 03:42:30PM -0800, Andrew Morton wrote:
> >> On Tue, 08 Mar 2011 22:32:26 +0100
> >> roel <roel.kluin@gmail.com> wrote:
> >>
> >>> Index i was already used in the outer loop
> >>>
> >>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> >>> ---
> >>>  fs/nfsd/nfs4xdr.c |    4 ++--
> >>>  1 files changed, 2 insertions(+), 2 deletions(-)
> >>>
> >>> Not 100% sure this one is needed but it looks suspicious.
> >>>
> >>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >>> index 1275b86..615f0a9 100644
> >>> --- a/fs/nfsd/nfs4xdr.c
> >>> +++ b/fs/nfsd/nfs4xdr.c
> >>> @@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >>>  
> >>>  	u32 dummy;
> >>>  	char *machine_name;
> >>> -	int i;
> >>> +	int i, j;
> >>>  	int nr_secflavs;
> >>>  
> >>>  	READ_BUF(16);
> >>> @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >>>  			READ_BUF(4);
> >>>  			READ32(dummy);
> >>>  			READ_BUF(dummy * 4);
> >>> -			for (i = 0; i < dummy; ++i)
> >>> +			for (j = 0; j < dummy; ++j)
> >>>  				READ32(dummy);
> >>>  			break;
> >>>  		case RPC_AUTH_GSS:
> >> ooh, big bug.
> >>
> >> I wonder why it was not previously detected at runtime.  Perhaps
> >> nr_secflavs is always 1.
> > 
> > Yeah, no client uses this calback security information yet.
> > 
> > Mi Jinlong, do you think this is something we could have caught with
> > another pynfs test?
> 
>   Yes, we must test it.
> 
>   After testing, the following test case is OK.

I've pushed out a tree with your additional tests to

	git://linux-nfs.org/~bfields/pynfs41.git

Let me know what I'm missing.

Thanks again.--b.

> 
> --
> thanks,
> Mi Jinlong
> 
> 
> >From 1afac3444b37bac66970f19c409660a304a53fb4 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Sun, 11 Mar 2011 09:05:22 +0800
> Subject: [PATCH] CLNT: test a decode problem which use wrong index
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_create_session.py |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> index ff55d10..e3a8421 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -252,6 +252,22 @@ def testCbSecParms(t, env):
>      c1 = env.c1.new_client(env.testname(t))
>      sess1 = c1.create_session(sec=sec)
>  
> +def testCbSecParmsDec(t, env):
> +    """A decode problem was found at NFS server that 
> +       wrong index used in inner loop, 
> +       http://marc.info/?l=linux-kernel&m=129961996327640&w=2
> +
> +    FLAGS: create_session all
> +    CODE: CSESS16a
> +    """
> +    sec = [callback_sec_parms4(AUTH_NONE),
> +           callback_sec_parms4(RPCSEC_GSS, cbsp_gss_handles=gss_cb_handles4(RPC_GSS_SVC_PRIVACY, "Handle from server", "Client handle")),
> +           callback_sec_parms4(AUTH_SYS, cbsp_sys_cred=authsys_parms(5, "Random machine name", 7, 11, [])),
> +           ]
> +                               
> +    c1 = env.c1.new_client(env.testname(t))
> +    sess1 = c1.create_session(sec=sec)
> +
>  def testRdmaArray0(t, env):
>      """Test 0 length rdma arrays
>  
> -- 
> 1.7.4.1
> 
> 
