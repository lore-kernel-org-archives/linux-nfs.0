Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059Ab1KWOVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 09:21:20 -0500
Message-ID: <4ECD015D.6040205@RedHat.com>
Date: Wed, 23 Nov 2011 09:21:17 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsidmap: Allow all keys to clear on the keyring
References: <1321566696-7298-1-git-send-email-steved@redhat.com> <1321566696-7298-2-git-send-email-steved@redhat.com> <20111122205300.GE21451@fieldses.org>
In-Reply-To: <20111122205300.GE21451@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/22/2011 03:53 PM, J. Bruce Fields wrote:
> On Thu, Nov 17, 2011 at 04:51:35PM -0500, Steve Dickson wrote:
>> Introduce the '-c [keyring]' command line argument
>> which will clear the giving keyring of the keys.
>> If a keyring not supplied the default 'id_resolver'
>> keyring will be used.
> 
> Is there any reason why an idmapping command should touch any keyring
> other than an id_resolver keyring?
> 
> If not I'd be inclined to leave that option out.
I'm all for making it simpler... 

> 
>> +#define DEFAULT_KEYRING "id_resolver"
>> +#define PROCKEYS "/proc/keys"
> ...
>> +	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
>> +		xlog_err("fopen(%s) failed: %m", PROCKEYS);
>> +		return 1;
>> +	}
>> +
>> +	while(fgets(buf, BUFSIZ, fp) != NULL) {
>> +		if (strstr(buf, "keyring") == NULL)
>> +			continue;
>> +		if (strstr(buf, keyring) == NULL)
>> +			continue;
> 
> Is grepping through /proc/keys really the right way to find this
> keyring?  
This was how David suggested I do it... 
 
> Documentation/security/keys.txt would have me believe that
> this sort of thing should work even with KEYS_DEBUG_PROC_KEYS not
> defined.  Maybe we want something like keyctl_search() ??
Well the first argument to keyctl_search is the serial number 
of the keyring. I believe the only way to get number is from
/proc/keys.

steved.

> 
> --b.
> 
>> +		if (verbose) {
>> +			*(strchr(buf, '\n')) = '\0';
>> +			xlog_warn("clearing '%s'", buf);
>> +		}
>> +		/*
>> +		 * The key is the first arugment in the string
>> +		 */
>> +		*(strchr(buf, ' ')) = '\0';
>> +		sscanf(buf, "%x", &key);
>> +		if (keyctl_clear(key) < 0) {
>> +			xlog_err("keyctl_clear(0x%x) failed: %m", key);
>> +			fclose(fp);
>> +			return 1;
>> +		}
>> +		fclose(fp);
>> +		return 0;
>> +	}
>> +	xlog_err("'%s' keyring was not found.", keyring);
>> +	fclose(fp);
>> +	return 1;
>> +}
>>  
>>  int main(int argc, char **argv)
>>  {
>> @@ -96,7 +142,8 @@ int main(int argc, char **argv)
>>  	int rc = 1, opt;
>>  	int timeout = 600;
>>  	key_serial_t key;
>> -	char *progname;
>> +	char *progname, *keyring = NULL;
>> +	int clearring;
>>  
>>  	/* Set the basename */
>>  	if ((progname = strrchr(argv[0], '/')) != NULL)
>> @@ -105,11 +152,12 @@ int main(int argc, char **argv)
>>  		progname = argv[0];
>>  
>>  	xlog_open(progname);
>> -	xlog_syslog(1);
>> -	xlog_stderr(0);
>>  
>> -	while ((opt = getopt(argc, argv, "t:v")) != -1) {
>> +	while ((opt = getopt(argc, argv, "ct:v")) != -1) {
>>  		switch (opt) {
>> +		case 'c':
>> +			clearring++;
>> +			break;
>>  		case 'v':
>>  			verbose++;
>>  			break;
>> @@ -122,6 +170,13 @@ int main(int argc, char **argv)
>>  		}
>>  	}
>>  
>> +	if (clearring) {
>> +		keyring = ((argc - optind) ? argv[optind] : NULL);
>> +		rc = keyring_clear(keyring);
>> +		return rc;		
>> +	}
>> +
>> +	xlog_stderr(0);
>>  	if ((argc - optind) != 2) {
>>  		xlog_err("Bad arg count. Check /etc/request-key.conf");
>>  		xlog_warn(usage, progname);
>> diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
>> index c67aab6..db65a1f 100644
>> --- a/utils/nfsidmap/nfsidmap.man
>> +++ b/utils/nfsidmap/nfsidmap.man
>> @@ -6,7 +6,7 @@
>>  .SH NAME
>>  nfsidmap \- The NFS idmapper upcall program
>>  .SH SYNOPSIS
>> -.B "nfsidmap [-v] [-t timeout] key desc"
>> +.B "nfsidmap [-v] [-c [keyring]] [-t timeout] key desc"
>>  .SH DESCRIPTION
>>  The file
>>  .I /usr/sbin/nfsidmap
>> @@ -14,10 +14,20 @@ is used by the NFS idmapper to translate user and group ids into names, and to
>>  translate user and group names into ids. Idmapper uses request-key to perform
>>  the upcall and cache the result.
>>  .I /usr/sbin/nfsidmap
>> -should only be called by request-key, and will perform the translation and
>> +is called by /sbin/request-key, and will perform the translation and
>>  initialize a key with the resulting information.
>> +.PP
>> +.I nfsidmap
>> +can also used to clear the keyring of all the keys.  
>> +This is useful when all the mappings have failed to due to an DNS outage
>> +or some other error resulting in all the cached uid/gid to be invalid.
>>  .SH OPTIONS
>>  .TP
>> +.B -c [keyring]
>> +Clear the keyring of all the keys. If a
>> +keyring is not supplied the default 
>> +keyring 'id_resolver' will be used.
>> +.TP
>>  .B -t timeout
>>  Set the expiration timer, in seconds, on the key.
>>  The default is 600 seconds (10 mins).
>> -- 
>> 1.7.7
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
