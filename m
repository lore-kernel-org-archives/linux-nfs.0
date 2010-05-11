From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [Fwd: newpynfs: compound test 6 fails]
Date: Tue, 11 May 2010 14:52:45 -0400
Message-ID: <AANLkTimsfSKzs1sTGVmLN59S-em9BduIOgAE6HI1Om_c@mail.gmail.com>
References: <1273599822.2810.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Vikas Chhabra <Vikas.Chhabra-IdkZ5yI5K0tWk0Htik3J/w@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:12704 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab0EKSws convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 14:52:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1480106fgg.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 11:52:46 -0700 (PDT)
In-Reply-To: <1273599822.2810.6.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 11, 2010 at 1:43 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> Forwarding to the NFS mailing list...
>
> -------- Forwarded Message --------
> From: Vikas Chhabra <Vikas.Chhabra-IdkZ5yI5K0tWk0Htik3J/w@public.gmane.org>
> To: mailman-owner@linux-nfs.org
> Subject: newpynfs: compound test 6 fails
> Date: Tue, 11 May 2010 10:48:31 +0530
>
> On Linux nfsv4 while executing newpynfs test suite COMP6 (testLongCom=
pound) fails with following error:
> COMP6 =A0 st_compound.testLongCompound =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 : FAILURE
> =A0 =A0 =A0 =A0COMPOUND with len=3D150 argarry got RPCError:
> =A0 =A0 =A0 =A0MSG_ACCEPTED: GARBAGE_ARGS, expected NFS4ERR_RESOURCE
>
>
>
> Could you please advice whether this could be a bug with Linux nfsv4
> implementation or does it look to be an issue with newpynfs test suit=
e
> itself?
>

GARBAGE_ARGS seems to be a reasonable response, if it is being failed
at the rpc layer instead of by nfs.

I'll update the test.

=46red

>
>
> Thanks in advance!!! Anticipating a quick help in this regard.
>
>
>
> -Vikas Chhabra
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
