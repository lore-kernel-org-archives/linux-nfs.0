From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs4 over rdma transport oops
Date: Thu, 28 Feb 2008 03:13:58 -0500
Message-ID: <EXNANE01Kd6QR7j1HaK000000f4@exnane01.hq.netapp.com>
References: <EXNANE01nwpGR881Np7000000e3@exnane01.hq.netapp.com>
 <4a4634330802272049xe20ef80y21c2c59f55932c70@mail.gmail.com> <4a4634330802272049xe20ef80y21c2c59f55932c70@mail.gmail.com
 >
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29381 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbYB1IPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2008 03:15:07 -0500
In-Reply-To: <4a4634330802272049xe20ef80y21c2c59f55932c70-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
 >
References: <EXNANE01nwpGR881Np7000000e3-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <4a4634330802272049xe20ef80y21c2c59f55932c70-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 11:49 PM 2/27/2008, Shirish Pargaonkar wrote:
>The code fix works.  I did not apply the workaround you had mentioned earlier
>and did not encounter oops for the same operation (cat) on the file on the
>mounted filesystem.

Great! I'll send it along to Trond then.

If you have a chance after running for a while on an RDMA mount
point, I'd be interested in the output of Chuck's "mountstats" python
script, which can extract some of the rdma operation statistics from the
rpc/rdma code. The "hardway" statistic is the one I'm especially interested
in, in your NFSv4 case. You can get it at:
	http://oss.oracle.com/~cel/linux-2.6/2.6.24/mountstats

There is also another script there which shows some very interesting
timing and other performance data, which I recommend:
	http://oss.oracle.com/~cel/linux-2.6/2.6.24/nfs-iostat

Thanks,

Tom.

