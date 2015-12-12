Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbbLLMQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:16:17 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 91EF6552E7
	for <linux-nfs@vger.kernel.org>; Sat, 12 Dec 2015 12:16:17 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v2 1/2] mountstats: handle KeyError in
 accumulate_iostats()
To: Scott Mayhew <smayhew@redhat.com>
References: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C1010.3020502@RedHat.com>
Date: Sat, 12 Dec 2015 07:16:16 -0500
MIME-Version: 1.0
In-Reply-To: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/10/2015 12:07 PM, Scott Mayhew wrote:
> This will prevent a backtrace like this from occurring in 'mountstats
> nfsstat' if a new NFSv4 operation is added to the kernel but not to the
> Nfsv4ops list in mountstats.py:
> 
> Traceback (most recent call last):
>   File "/sbin/mountstats", line 988, in <module>
>     res = main()
>   File "/sbin/mountstats", line 977, in main
>     return args.func(args)
>   File "/sbin/mountstats", line 792, in nfsstat_command
>     v4stats.accumulate_iostats(acc_stats)
>   File "/sbin/mountstats", line 566, in accumulate_iostats
>     self.__rpc_data[op] = list(map(add, self.__rpc_data[op],
> new_stats.__rpc_data[op]))
> KeyError: 'SEEK'
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  tools/mountstats/mountstats.py | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 011bb42..1e2811f 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -563,7 +563,10 @@ class DeviceData:
>          for the nfsstat command.
>          """
>          for op in new_stats.__rpc_data['ops']:
> -            self.__rpc_data[op] = list(map(add, self.__rpc_data[op], new_stats.__rpc_data[op]))
> +            try:
> +                self.__rpc_data[op] = list(map(add, self.__rpc_data[op], new_stats.__rpc_data[op]))
> +            except KeyError:
> +                continue
>  
>      def __print_rpc_op_stats(self, op, sample_time):
>          """Print generic stats for one RPC op
> 
