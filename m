Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752798Ab3JUNur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 09:50:47 -0400
Message-ID: <5265315D.9030008@RedHat.com>
Date: Mon, 21 Oct 2013 09:51:25 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Add -s option.
References: <1380734389-8202-1-git-send-email-tasleson@redhat.com> <20131002214015.GA20902@fieldses.org>
In-Reply-To: <20131002214015.GA20902@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/10/13 17:40, J. Bruce Fields wrote:
> On Wed, Oct 02, 2013 at 12:19:49PM -0500, Tony Asleson wrote:
>> Adds '-s' option which outputs the current exports in a format
>> suitable for /etc/exports.
> 
> Sounds like a good idea....
> 
> Is there any difference between this and what's written to
> /var/lib/nfs/etab?
Yes... The following options are in the etab but not in
the -s output... 

sync,hide,nocrossmnt,secure,no_all_squash,secure_locks,acl,anonuid=65534,anongid=65534

> 
> OK looks like the latter is more verbose--it doesn't skip default
> options.
The only real difference between -v and -s is -v uses the 
string "<world>" in for MCL_ANONYMOUS and -s uses "*" 

I guess we could change -v to used what the -s is proposing,
but that could break someone's existing configuration...  
> 
> Still can't help thinking there must be some needlessly duplicated code
> here.
There is... but I stilling adding the -s makes sense....

steved.

> 
> --b.
> 
>>
>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
>> ---
>>  utils/exportfs/exportfs.c   | 23 ++++++++++++++---------
>>  utils/exportfs/exportfs.man |  5 ++++-
>>  2 files changed, 18 insertions(+), 10 deletions(-)
>>
>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>> index 4331697..52fc03d 100644
>> --- a/utils/exportfs/exportfs.c
>> +++ b/utils/exportfs/exportfs.c
>> @@ -38,7 +38,7 @@ static void	export_all(int verbose);
>>  static void	exportfs(char *arg, char *options, int verbose);
>>  static void	unexportfs(char *arg, int verbose);
>>  static void	exports_update(int verbose);
>> -static void	dump(int verbose);
>> +static void	dump(int verbose, int export_format);
>>  static void	error(nfs_export *exp, int err);
>>  static void	usage(const char *progname, int n);
>>  static void	validate_export(nfs_export *exp);
>> @@ -88,6 +88,7 @@ main(int argc, char **argv)
>>  	int	f_export = 1;
>>  	int	f_all = 0;
>>  	int	f_verbose = 0;
>> +	int	f_export_format = 0;
>>  	int	f_reexport = 0;
>>  	int	f_ignore = 0;
>>  	int	i, c;
>> @@ -105,7 +106,7 @@ main(int argc, char **argv)
>>  
>>  	export_errno = 0;
>>  
>> -	while ((c = getopt(argc, argv, "afhio:ruv")) != EOF) {
>> +	while ((c = getopt(argc, argv, "afhio:ruvs")) != EOF) {
>>  		switch(c) {
>>  		case 'a':
>>  			f_all = 1;
>> @@ -132,6 +133,9 @@ main(int argc, char **argv)
>>  		case 'v':
>>  			f_verbose = 1;
>>  			break;
>> +		case 's':
>> +			f_export_format = 1;
>> +			break;
>>  		default:
>>  			usage(progname, 1);
>>  			break;
>> @@ -164,7 +168,7 @@ main(int argc, char **argv)
>>  			return 0;
>>  		} else {
>>  			xtab_export_read();
>> -			dump(f_verbose);
>> +			dump(f_verbose, f_export_format);
>>  			return 0;
>>  		}
>>  	}
>> @@ -634,7 +638,7 @@ dumpopt(char c, char *fmt, ...)
>>  }
>>  
>>  static void
>> -dump(int verbose)
>> +dump(int verbose, int export_format)
>>  {
>>  	nfs_export	*exp;
>>  	struct exportent *ep;
>> @@ -647,14 +651,15 @@ dump(int verbose)
>>  			if (!exp->m_xtabent)
>>  			    continue; /* neilb */
>>  			if (htype == MCL_ANONYMOUS)
>> -				hname = "<world>";
>> +				hname = (export_format) ? "*" : "<world>";
>>  			else
>>  				hname = ep->e_hostname;
>> -			if (strlen(ep->e_path) > 14)
>> +			if (strlen(ep->e_path) > 14 && !export_format)
>>  				printf("%-14s\n\t\t%s", ep->e_path, hname);
>>  			else
>> -				printf("%-14s\t%s", ep->e_path, hname);
>> -			if (!verbose) {
>> +				printf(((export_format)? "%s %s" : "%-14s\t%s"), ep->e_path, hname);
>> +
>> +			if (!verbose && !export_format) {
>>  				printf("\n");
>>  				continue;
>>  			}
>> @@ -728,6 +733,6 @@ error(nfs_export *exp, int err)
>>  static void
>>  usage(const char *progname, int n)
>>  {
>> -	fprintf(stderr, "usage: %s [-afhioruv] [host:/path]\n", progname);
>> +	fprintf(stderr, "usage: %s [-afhioruvs] [host:/path]\n", progname);
>>  	exit(n);
>>  }
>> diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
>> index 8853486..590f9cf 100644
>> --- a/utils/exportfs/exportfs.man
>> +++ b/utils/exportfs/exportfs.man
>> @@ -3,7 +3,7 @@
>>  .\" Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
>>  .\" Modifications 1999-2003 Neil Brown <neilb@cse.unsw.edu.au>
>>  .\"
>> -.TH exportfs 8 "31 December 2009"
>> +.TH exportfs 8 "30 September 2013"
>>  .SH NAME
>>  exportfs \- maintain table of exported NFS file systems
>>  .SH SYNOPSIS
>> @@ -133,6 +133,9 @@ when they make their next NFS mount request.
>>  Be verbose. When exporting or unexporting, show what's going on. When
>>  displaying the current export list, also display the list of export
>>  options.
>> +.TP
>> +.B -s
>> +Display the current export list suitable for /etc/exports.
>>  .SH DISCUSSION
>>  .SS Exporting Directories
>>  The first synopsis shows how to invoke
>> -- 
>> 1.8.2.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
