Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbbCDNMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2015 08:12:25 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t24DCO36017322
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 4 Mar 2015 08:12:25 -0500
Message-ID: <54F704B7.5030208@RedHat.com>
Date: Wed, 04 Mar 2015 08:12:23 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Scott Mayhew <smayhew@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] mountstats: Normalize the mountpoints passed
 on the command line.
References: <1425410119-30725-1-git-send-email-smayhew@redhat.com>
In-Reply-To: <1425410119-30725-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/03/2015 02:15 PM, Scott Mayhew wrote:
> Normalize the mountpoints passed on the command line so that commands
> like 'mountstats /mnt/' succeed rather than fail.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.

> ---
>  tools/mountstats/mountstats.py | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 7f5dee1..38943eb 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -686,7 +686,7 @@ def mountstats_command(args):
>      """Mountstats command
>      """
>      mountstats = parse_stats_file(args.infile)
> -    mountpoints = args.mountpoints
> +    mountpoints = [os.path.normpath(mp) for mp in args.mountpoints]
>  
>      # make certain devices contains only NFS mount points
>      if len(mountpoints) > 0:
> @@ -735,7 +735,7 @@ def nfsstat_command(args):
>      """nfsstat-like command for NFS mount points
>      """
>      mountstats = parse_stats_file(args.infile)
> -    mountpoints = args.mountpoints
> +    mountpoints = [os.path.normpath(mp) for mp in args.mountpoints]
>      v3stats = DeviceData()
>      v3stats.setup_accumulator(Nfsv3ops)
>      v4stats = DeviceData()
> @@ -822,7 +822,7 @@ def iostat_command(args):
>      """iostat-like command for NFS mount points
>      """
>      mountstats = parse_stats_file(args.infile)
> -    devices = args.mountpoints
> +    devices = [os.path.normpath(mp) for mp in args.mountpoints]
>  
>      if args.since:
>          old_mountstats = parse_stats_file(args.since)
> -- 1.9.3
> 
