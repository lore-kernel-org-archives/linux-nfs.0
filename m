Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbaGYPBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jul 2014 11:01:15 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6PF1Eha031406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 11:01:14 -0400
Message-ID: <53D27138.5010406@RedHat.com>
Date: Fri, 25 Jul 2014 11:01:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Slavek Kabrda <bkabrda@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix Python 3 compatibility of mountstats and nfs-iostat
References: <1405591052-17456-1-git-send-email-bkabrda@redhat.com>
In-Reply-To: <1405591052-17456-1-git-send-email-bkabrda@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/07/14 05:57, Slavek Kabrda wrote:
> Signed-off-by: Slavek Kabrda <bkabrda@redhat.com>
Committed... 

steved.
> ---
>  tools/mountstats/mountstats.py | 2 +-
>  tools/nfs-iostat/nfs-iostat.py | 3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index e46105d..1fb3e2f 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -371,7 +371,7 @@ def parse_stats_file(filename):
>      ms_dict = dict()
>      key = ''
>  
> -    f = file(filename)
> +    f = open(filename)
>      for line in f.readlines():
>          words = line.split()
>          if len(words) == 0:
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index b324cd8..61d15a5 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -213,7 +213,8 @@ class DeviceData:
>          # the reference to them.  so we build new lists here
>          # for the result object.
>          for op in result.__rpc_data['ops']:
> -            result.__rpc_data[op] = map(difference, self.__rpc_data[op], old_stats.__rpc_data[op])
> +            result.__rpc_data[op] = list(map(
> +                difference, self.__rpc_data[op], old_stats.__rpc_data[op]))
>  
>          # update the remaining keys we care about
>          result.__rpc_data['rpcsends'] -= old_stats.__rpc_data['rpcsends']
> 
