From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 05 Dec 2008 13:42:18 -0500
Message-ID: <4939760A.9050304@RedHat.com>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown> <20081205035803.GC15115@fieldses.org> <49392C14.7000709@RedHat.com> <20081205163824.GA29227@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42001 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210AbYLESol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 13:44:41 -0500
In-Reply-To: <20081205163824.GA29227@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Dec 05, 2008 at 08:26:44AM -0500, Steve Dickson wrote:
>> J. Bruce Fields wrote:
>>>> I think it would still be valuable to replace the 'sync' with two
>>>> 'fsync's, one of the file, one on the directory.
>>> Sure, may as well.--b.
>>>
>> Something similar to this:
>>
>> diff -up nfs-utils/utils/statd/sm-notify.c.orig nfs-utils/utils/statd/sm-notify.c
>> --- nfs-utils/utils/statd/sm-notify.c.orig	2008-11-17 15:06:13.000000000 -0500
>> +++ nfs-utils/utils/statd/sm-notify.c	2008-12-05 08:21:52.000000000 -0500
>> @@ -211,12 +211,6 @@ usage:		fprintf(stderr,
>>  	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
>>  	get_hosts(_SM_BAK_PATH);
>>  
>> -	/* If there are not hosts to notify, just exit */
>> -	if (!hosts) {
>> -		nsm_log(LOG_DEBUG, "No hosts to notify; exiting");
>> -		return 0;
>> -	}
> 
> This was still a huge boot-time win in the common case, so now that
> we've committed to it I'd rather not regress.  
I thought the idea was the state had to be updated even when there
are no hosts...

>> @@ -730,13 +725,16 @@ nsm_get_state(int update)
>>  				"Failed to write state to %s", newfile);
>>  			exit(1);
>>  		}
>> +		fsync(fd);
>>  		close(fd);
>> +		fp = opendir(_SM_STATE_PATH);
> 
> Also, I think you meant to:
> 
> 		fsync(fp);
> 		close(fp);
No... I don't think so... the fd is an open() of the new file and the
fp is a DIR stream... But there was a cut/paste error... The fsync()
of the DIR stream was missing... here is is again...

@@ -694,6 +688,7 @@ nsm_get_state(int update)
 {
 	char		newfile[PATH_MAX];
 	int		fd, state;
+	DIR 	*fp;
 
 	if ((fd = open(_SM_STATE_PATH, O_RDONLY)) < 0) {
 		if (!opt_quiet) {
@@ -730,13 +725,18 @@ nsm_get_state(int update)
 				"Failed to write state to %s", newfile);
 			exit(1);
 		}
+		fsync(fd);
 		close(fd);
+		fp = opendir(_SM_STATE_PATH);
 		if (rename(newfile, _SM_STATE_PATH) < 0) {
 			nsm_log(LOG_ERR,
 				"Cannot create %s: %m", _SM_STATE_PATH);
 			exit(1);
 		}
-		sync();
+		if (fp != NULL) {
+			fsync(dirfd(fp));
+			closedir(fp);
+		}
 	}
 
 	return state;

