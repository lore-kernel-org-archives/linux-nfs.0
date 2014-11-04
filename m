Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbaKDTEn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 14:04:43 -0500
Message-ID: <54592349.4030504@RedHat.com>
Date: Tue, 04 Nov 2014 14:04:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountstats: Don't display retrans stats unless there
 are re-xmits
References: <20141031211917.13278.61844.stgit@manet.1015granger.net>
In-Reply-To: <20141031211917.13278.61844.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/31/2014 05:19 PM, Chuck Lever wrote:
> Clean up display of RPC statistics by omitting retransmit statistics
> when there have been no retransmissions.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  tools/mountstats/mountstats.py |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 1fb3e2f..9a6ec43 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -272,8 +272,11 @@ class DeviceData:
>                  print('%s:' % op)
>                  print('\t%d ops (%d%%)' % \
>                      (count, ((count * 100) / sends)), end=' ')
> -                print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
> -                print('\t%d major timeouts' % stats[2])
> +                if retrans != 0:
> +                    print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
> +                    print('\t%d major timeouts' % stats[2])
> +                else:
> +                    print('')
>                  print('\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
>                      (stats[3] / count, stats[4] / count))
>                  print('\tbacklog wait: %f' % (float(stats[5]) / count), end=' ')
> 
