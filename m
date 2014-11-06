Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:50544 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaKFBwo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 20:52:44 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [nfs-utils RFC PATCH 05/15] mountstats: Convert existing option parsing to use the getopt module
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1415206872-864-6-git-send-email-smayhew@redhat.com>
Date: Wed, 5 Nov 2014 20:52:39 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <721A2038-04AF-433C-A0AE-C677C7FF041F@oracle.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com> <1415206872-864-6-git-send-email-smayhew@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 5, 2014, at 12:01 PM, Scott Mayhew <smayhew@redhat.com> wrote:

I’m not clear why you need to replace this code. But if
you really do need to replace it, why not use the more
Python-esque argparse module, which would replace both
the option parsing and help text?

> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
> tools/mountstats/mountstats.py | 62 +++++++++++++++++++++---------------------
> 1 file changed, 31 insertions(+), 31 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 2fe1362..272a8f9 100755
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -24,6 +24,7 @@ MA 02110-1301 USA
> """
> 
> import sys, os, time
> +import getopt
> 
> Mountstats_version = '0.2'
> 
> @@ -547,37 +548,33 @@ def print_mountstats_help(name):
> def mountstats_command():
>     """Mountstats command
>     """
> +    try:
> +        opts, args = getopt.getopt(sys.argv[1:], "ehnrsv", ["end", "help", "nfs", "rpc", "start", "version"])
> +    except getopt.GetoptError as err:
> +        print_mountstats_help(prog)
> +
>     mountpoints = []
>     nfs_only = False
>     rpc_only = False
> 
> -    for arg in sys.argv:
> -        if arg in ['-h', '--help', 'help', 'usage']:
> +    for o, a in opts:
> +        if o in ("-e", "--end"):
> +            raise Exception('Sampling is not yet implemented')
> +        elif o in ("-h", "--help"):
>             print_mountstats_help(prog)
> -            return
> -
> -        if arg in ['-v', '--version', 'version']:
> -            print('%s version %s' % (sys.argv[0], Mountstats_version))
>             sys.exit(0)
> -
> -        if arg in ['-n', '--nfs']:
> +        elif o in ("-n", "--nfs"):
>             nfs_only = True
> -            continue
> -
> -        if arg in ['-r', '--rpc']:
> +        elif o in ("-r", "--rpc"):
>             rpc_only = True
> -            continue
> -
> -        if arg in ['-s', '--start']:
> -            raise Exception('Sampling is not yet implemented')
> -
> -        if arg in ['-e', '--end']:
> +        elif o in ("-s", "--start"):
>             raise Exception('Sampling is not yet implemented')
> -
> -        if arg == sys.argv[0]:
> -            continue
> -
> -        mountpoints += [arg]
> +        elif o in ("-v", "--version"):
> +            print('%s version %s' % (sys.argv[0], Mountstats_version))
> +            sys.exit(0)
> +        else:
> +            assert False, "unhandled option"
> +    mountpoints += args
> 
>     if mountpoints == []:
>         print_mountstats_help(prog)
> @@ -662,23 +659,26 @@ def print_iostat_summary(old, new, devices, time):
> def iostat_command():
>     """iostat-like command for NFS mount points
>     """
> +    try:
> +        opts, args = getopt.getopt(sys.argv[1:], "hv", ["help", "version"])
> +    except getopt.GetoptError as err:
> +        print_iostat_help(prog)
>     mountstats = parse_stats_file('/proc/self/mountstats')
>     devices = []
>     interval_seen = False
>     count_seen = False
> 
> -    for arg in sys.argv:
> -        if arg in ['-h', '--help', 'help', 'usage']:
> +    for o, a in opts:
> +        if o in ("-h", "--help"):
>             print_iostat_help(prog)
> -            return
> -
> -        if arg in ['-v', '--version', 'version']:
> +            sys.exit(0)
> +        elif o in ("-v", "--version"):
>             print('%s version %s' % (sys.argv[0], Mountstats_version))
> -            return
> -
> -        if arg == sys.argv[0]:
> -            continue
> +            sys.exit(0)
> +        else:
> +            assert False, "unhandled option"
> 
> +    for arg in args:
>         if arg in mountstats:
>             devices += [arg]
>         elif not interval_seen:
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



