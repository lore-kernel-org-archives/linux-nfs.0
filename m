Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbaKFSeq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2014 13:34:46 -0500
Message-ID: <545BBF3B.4040003@RedHat.com>
Date: Thu, 06 Nov 2014 13:34:35 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: bstroesser@ts.fujitsu.com, libtirpc-devel@lists.sourceforge.net,
        "nfs >> Linux NFS Mailing list" <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [libtirpc-devel] [PATCH] Fix write retry loop
 for nonblocking mode
References: <d6437a$66h60b@dgate10u.abg.fsc.net>
In-Reply-To: <d6437a$66h60b@dgate10u.abg.fsc.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/30/2014 09:17 AM, bstroesser@ts.fujitsu.com wrote:
> Hello,
> 
> while testing with rpcbind, I stumbled across a small
> bug in libtirpc. I didn't test the patch below, but
> I think it's quite obvious.
> 
> Please CC me, I'm not on the list.
> 
> Best regards
> Bodo
> 
> 
> ----------
> 
> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Tue, 30 Sep 2014 14:01:17 +0200
> Subject: [PATCH] fix write retry loop for nonblocking mode
> 
> This is a simple fix for the write retry loop that is used on
> non-blocking connections if write() failed with -EAGAIN.
> 
> Additionally it removes a redundant if () {}
> 
> Erroneously at each cycle of the loop the length of the data
> to send is incremented and the buffer pointer is decremented.
> Thus, it might happen that:
> * the application crashes
> * data from the memory before the buffer is sent
> 
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Committed....

steved.

> 
> ---------
> 
> --- libtirpc-0.2.5/src/svc_vc.c	2014-09-30 14:56:42.000000000 +0200
> +++ libtirpc-0.2.5/src/svc_vc.c	2014-09-30 15:03:56.000000000 +0200
> @@ -559,20 +559,19 @@ write_vc(xprtp, buf, len)
>  				cd->strm_stat = XPRT_DIED;
>  				return (-1);
>  			}
> -			if (cd->nonblock && i != cnt) {
> -				/*
> -				 * For non-blocking connections, do not
> -				 * take more than 2 seconds writing the
> -				 * data out.
> -				 *
> -				 * XXX 2 is an arbitrary amount.
> -				 */
> -				gettimeofday(&tv1, NULL);
> -				if (tv1.tv_sec - tv0.tv_sec >= 2) {
> -					cd->strm_stat = XPRT_DIED;
> -					return (-1);
> -				}
> +			/*
> +			 * For non-blocking connections, do not
> +			 * take more than 2 seconds writing the
> +			 * data out.
> +			 *
> +			 * XXX 2 is an arbitrary amount.
> +			 */
> +			gettimeofday(&tv1, NULL);
> +			if (tv1.tv_sec - tv0.tv_sec >= 2) {
> +				cd->strm_stat = XPRT_DIED;
> +				return (-1);
>  			}
> +			i = 0; /* Don't change buf and cnt */
>  		}
>  	}
>  
> ------------------------------------------------------------------------------
> Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
> Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
> Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
> Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
> http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
> 
