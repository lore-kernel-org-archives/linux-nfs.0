Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753868AbdLTPCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 10:02:21 -0500
Subject: Re: [PATCH] mountstats: Use correct RDMA terminology
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
References: <20171219163529.10803.82407.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <cda935cf-40b3-30e0-8b3e-a9f4c80f97b2@RedHat.com>
Date: Wed, 20 Dec 2017 10:02:20 -0500
MIME-Version: 1.0
In-Reply-To: <20171219163529.10803.82407.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/19/2017 11:35 AM, Chuck Lever wrote:
> The kernel is counting RDMA segments, not chunks. Correct the units
> labels displayed by "mountstats -x", and fix up the internal names
> of the counters.
> 
> Fixes: 6742ba53ae79 ("mountstats: Add option to pretty-print ...")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.
> ---
>  tools/mountstats/mountstats.py |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 440aa72..c7fb8bb 100755
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -120,9 +120,9 @@ XprtRdmaCounters = [
>      'badxids',
>      'inflightsends',
>      'backlogutil',
> -    'read_chunks',
> -    'write_chunks',
> -    'reply_chunks',
> +    'read_segments',
> +    'write_segments',
> +    'reply_segments',
>      'total_rdma_req',
>      'total_rdma_rep',
>      'pullup',
> @@ -718,9 +718,9 @@ class DeviceData:
>              if self.__rpc_data['rpcsends'] != 0:
>                  print('\tAvg backlog length: %d' % \
>                      (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
> -            print('\tRead chunks: %d' % self.__rpc_data['read_chunks'])
> -            print('\tWrite chunks: %d' % self.__rpc_data['write_chunks'])
> -            print('\tReply chunks: %d' % self.__rpc_data['reply_chunks'])
> +            print('\tRead segments: %d' % self.__rpc_data['read_segments'])
> +            print('\tWrite segments: %d' % self.__rpc_data['write_segments'])
> +            print('\tReply segments: %d' % self.__rpc_data['reply_segments'])
>              print('\tRegistered: %d bytes' % self.__rpc_data['total_rdma_req'])
>              print('\tRDMA received: %d bytes' % self.__rpc_data['total_rdma_rep'])
>              print('\tTotal pull-up: %d bytes' % self.__rpc_data['pullup'])
> 
