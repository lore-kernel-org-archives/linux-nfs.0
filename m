Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092Ab2CGUxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 15:53:04 -0500
Message-ID: <4F57CAB4.2050500@RedHat.com>
Date: Wed, 07 Mar 2012 15:53:08 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] exportfs: Stop racing exportfs on clusters
References: <1331150190-18401-1-git-send-email-steved@redhat.com> <20120307203649.GA582@fieldses.org>
In-Reply-To: <20120307203649.GA582@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2012 03:36 PM, J. Bruce Fields wrote:
> On Wed, Mar 07, 2012 at 02:56:30PM -0500, Steve Dickson wrote:
>> This problem can occur when multiple cluster services fail over
>> at the same time, causing missing high-available exports.
>> Having a lot of nfs-exports will trigger this issue easier.
> 
> Isn't the locking in support/export/xtab.c supposed to take care of
> this?
> 
> I may be confused--I forget what all these files are for....
hmm... your right... those do take out flock()s during I/O..
There must be a hole somewhere they can get corrupted... 

steved.

> 
> --b.
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  support/include/exportfs.h |    4 ++++
>>  utils/exportfs/exportfs.c  |   24 ++++++++++++++++++++++++
>>  2 files changed, 28 insertions(+), 0 deletions(-)
>>
>> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
>> index 01e87dd..99916e5 100644
>> --- a/support/include/exportfs.h
>> +++ b/support/include/exportfs.h
>> @@ -32,6 +32,10 @@ enum {
>>  	FSLOC_STUB
>>  };
>>  
>> +#ifndef EXP_LOCKFILE
>> +#define EXP_LOCKFILE "/var/lib/nfs/export-lock"
>> +#endif
>> +
>>  typedef struct mclient {
>>  	struct mclient *	m_next;
>>  	char *			m_hostname;
>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>> index 7432a65..769d438 100644
>> --- a/utils/exportfs/exportfs.c
>> +++ b/utils/exportfs/exportfs.c
>> @@ -16,6 +16,7 @@
>>  #include <sys/stat.h>
>>  #include <sys/vfs.h>
>>  #include <sys/stat.h>
>> +#include <sys/file.h>
>>  #include <unistd.h>
>>  #include <stdbool.h>
>>  #include <stdlib.h>
>> @@ -44,6 +45,23 @@ static void	validate_export(nfs_export *exp);
>>  static int	matchhostname(const char *hostname1, const char *hostname2);
>>  static void	export_d_read(const char *dname);
>>  
>> +static const char *lockfile = EXP_LOCKFILE;
>> +static int _lockfd = -1;
>> +
>> +void 
>> +grab_lockfile()
>> +{
>> +	_lockfd = open(lockfile, O_CREAT|O_RDWR, 0666);
>> +	if (_lockfd != -1) 
>> +		lockf(_lockfd, F_LOCK, 0);
>> +}
>> +void 
>> +release_lockfile()
>> +{
>> +	if (_lockfd != -1)
>> +		lockf(_lockfd, F_ULOCK, 0);
>> +}
>> +
>>  int
>>  main(int argc, char **argv)
>>  {
>> @@ -129,6 +147,12 @@ main(int argc, char **argv)
>>  			return 0;
>>  		}
>>  	}
>> +	/*
>> +	 * Serialize things as best we can
>> +	 */
>> +	grab_lockfile();
>> +	atexit(release_lockfile);
>> +
>>  	if (f_export && ! f_ignore) {
>>  		export_read(_PATH_EXPORTS);
>>  		export_d_read(_PATH_EXPORTS_D);
>> -- 
>> 1.7.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
