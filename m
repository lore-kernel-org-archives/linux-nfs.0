Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347AbbCDNMr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2015 08:12:47 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t24DCkut023914
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 4 Mar 2015 08:12:46 -0500
Message-ID: <54F704CD.8090808@RedHat.com>
Date: Wed, 04 Mar 2015 08:12:45 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] mountstats: Fix exit code handling
References: <1425326415-60997-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1425326415-60997-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2015 03:00 PM, Scott Mayhew wrote:
> When I changed mountstats to use the argparse module, I neglected to
> make the subcommand functions return any values even though main() was
> looking for them.  Also removed SystemExit from the except clause at
> the end of the program since it was causing the program to always exit
> with a status of 1.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.

> ---
>  tools/mountstats/mountstats.py | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index fd73feb..7f5dee1 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -708,7 +708,7 @@ def mountstats_command(args):
>                  mountpoints += [device]
>      if len(mountpoints) == 0:
>          print('No NFS mount points were found')
> -        return
> +        return 1
>  
>      if args.since:
>          old_mountstats = parse_stats_file(args.since)
> @@ -729,6 +729,7 @@ def mountstats_command(args):
>      args.infile.close()
>      if args.since:
>          args.since.close()
> +    return 0
>  
>  def nfsstat_command(args):
>      """nfsstat-like command for NFS mount points
> @@ -766,7 +767,7 @@ def nfsstat_command(args):
>                  mountpoints += [device]
>      if len(mountpoints) == 0:
>          print('No NFS mount points were found')
> -        return
> +        return 1
>  
>      if args.since:
>          old_mountstats = parse_stats_file(args.since)
> @@ -803,6 +804,7 @@ def nfsstat_command(args):
>      args.infile.close()
>      if args.since:
>          args.since.close()
> +    return 0
>  
>  def print_iostat_summary(old, new, devices, time):
>      for device in devices:
> @@ -847,7 +849,7 @@ def iostat_command(args):
>                  devices += [device]
>      if len(devices) == 0:
>          print('No NFS mount points were found')
> -        return
> +        return 1
>  
>      sample_time = 0
>  
> @@ -875,6 +877,7 @@ def iostat_command(args):
>      args.infile.close()
>      if args.since:
>          args.since.close()
> +    return 0
>  
>  class ICMAction(argparse.Action):
>      """Custom action to deal with interval, count, and mountpoints.
> @@ -986,7 +989,7 @@ try:
>          sys.stdout.close()
>          sys.stderr.close()
>          sys.exit(res)
> -except (SystemExit, KeyboardInterrupt, RuntimeError):
> +except (KeyboardInterrupt, RuntimeError):
>      sys.exit(1)
>  except IOError:
>      pass
> -- 1.9.3
> 
