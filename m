Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbcEDNiP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2016 09:38:15 -0400
Subject: Re: [PATCH 2/2] gssd: move read of upcall into main thread
To: Olga Kornievskaia <kolga@netapp.com>
References: <1462286792-8889-1-git-send-email-kolga@netapp.com>
 <1462286792-8889-2-git-send-email-kolga@netapp.com>
 <50edf6a8-4d4c-07d5-af0a-363ac66dbfa5@RedHat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <dee84a6a-5a41-3922-4ce6-f72dff93c88a@RedHat.com>
Date: Wed, 4 May 2016 09:38:11 -0400
MIME-Version: 1.0
In-Reply-To: <50edf6a8-4d4c-07d5-af0a-363ac66dbfa5@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/04/2016 09:27 AM, Steve Dickson wrote:
> One very small nit... 
> 
> On 05/03/2016 10:46 AM, Olga Kornievskaia wrote:
>> This patch moves reading of the upcall information from the child thread
>> into the main thread. It removes the need to synchronize between the
>> parent and child thread before processing upcall. Also it creates the thread
>> in a detached state.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  utils/gssd/gssd.c      | 95 +++++++++++++++++++++++++++++++++++---------------
>>  utils/gssd/gssd.h      | 13 +++++--
>>  utils/gssd/gssd_proc.c | 73 +++++++++++---------------------------
>>  3 files changed, 98 insertions(+), 83 deletions(-)
>>
>> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
>> index 9bf7917..95b6715 100644
>> --- a/utils/gssd/gssd.c
>> +++ b/utils/gssd/gssd.c
>> @@ -363,54 +363,93 @@ gssd_destroy_client(struct clnt_info *clp)
>>  
>>  static void gssd_scan(void);
>>  
>> -static inline void 
>> -wait_for_child_and_detach(pthread_t th)
>> +static void
>> +start_upcall_thread(void (*func)(struct clnt_upcall_info *), void *info)
>> +{
>> +	pthread_attr_t attr;
>> +	pthread_t th;
>> +	int ret;
>> +
>> +	ret = pthread_attr_init(&attr);
>> +	if (ret != 0) {
>> +		printerr(0, "ERROR: failed to init pthread attr: ret %d: %s\n",
>> +			 ret, strerror(errno));
>> +		goto err;
>> +	}
>> +	ret = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
>> +	if (ret != 0) {
>> +		printerr(0, "ERROR: failed to create pthread attr: ret %d: "
>> +			 "%s\n", ret, strerror(errno));
>> +		goto err;
>> +	}
>> +
>> +	ret = pthread_create(&th, &attr, (void *)func, (void *)info);
>> +	if (ret != 0) {
>> +		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
>> +			 ret, strerror(errno));
>> +		goto err;
>> +	}
>> +	return;
>> +err:
>> +	free(info);
>> +}
>> +
>> +static struct clnt_upcall_info *alloc_upcall_info(struct clnt_info *clp)
>>  {
>> -	pthread_mutex_lock(&pmutex);
>> -	while (!thread_started)
>> -		pthread_cond_wait(&pcond, &pmutex);
>> -	thread_started = false;
>> -	pthread_mutex_unlock(&pmutex);
>> -	pthread_detach(th);
>> +	struct clnt_upcall_info *info;
>> +
>> +	info = malloc(sizeof(struct clnt_upcall_info));
>> +	if (info == NULL)
>> +		return NULL;
>> +	info->clp = clp;
>> +
>> +	return info;
>>  }
>>  
>> -/* For each upcall create a thread, detach from the main process so that
>> - * resources are released back into the system without the need for a join.
>> - * We need to wait for the child thread to start and consume the event from
>> - * the file descriptor.
>> +/* For each upcall read the upcall info into the buffer, then create a
>> + * thread in a detached state so that resources are released back into
>> + * the system without the need for a join.
>>   */
>>  static void
>>  gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
>>  {
>>  	struct clnt_info *clp = data;
>> -	pthread_t th;
>> -	int ret;
>> +	struct clnt_upcall_info *info;
>>  
>> -	ret = pthread_create(&th, NULL, (void *)handle_gssd_upcall,
>> -				(void *)clp);
>> -	if (ret != 0) {
>> -		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
>> -			 ret, strerror(errno));
>> +	info = alloc_upcall_info(clp);
>> +	if (info == NULL)
>> +		return;
>> +
>> +	info->lbuflen = read(clp->gssd_fd, info->lbuf, sizeof(info->lbuf));
>> +	if (info->lbuflen <= 0 || info->lbuf[info->lbuflen-1] != '\n') {
>> +		printerr(0, "WARNING: %s: failed reading request\n", __func__);
>> +		free(info);
>>  		return;
>>  	}
>> -	wait_for_child_and_detach(th);
>> +	info->lbuf[info->lbuflen-1] = 0;
>> +
>> +	start_upcall_thread(handle_gssd_upcall, info);
> Instead of having start_upcall_thread() free the info pointer
> I think it makes it more readable if gssd_clnt_gssd_cb() does the
> free... So the routine would allocate the pointer, populate the
> pointer and free the point all in one routine.
> 
> I think it would make start_upcall_thread() simpler since
> it would not need all those goto... 
If you are good with this... I'll make the changes... no
need to post a second versions... 

steved.

> 
> steved.
> 
>>  }
>>  
>>  static void
>>  gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
>>  {
>>  	struct clnt_info *clp = data;
>> -	pthread_t th;
>> -	int ret;
>> +	struct clnt_upcall_info *info;
>>  
>> -	ret = pthread_create(&th, NULL, (void *)handle_krb5_upcall,
>> -				(void *)clp);
>> -	if (ret != 0) {
>> -		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
>> -			 ret, strerror(errno));
>> +	info = alloc_upcall_info(clp);
>> +	if (info == NULL)
>> +		return;
>> +
>> +	if (read(clp->krb5_fd, &info->uid,
>> +			sizeof(info->uid)) < (ssize_t)sizeof(info->uid)) {
>> +		printerr(0, "WARNING: %s: failed reading uid from krb5 "
>> +			 "upcall pipe: %s\n", __func__, strerror(errno));
>> +		free(info);
>>  		return;
>>  	}
>> -	wait_for_child_and_detach(th);
>> +
>> +	start_upcall_thread(handle_krb5_upcall, info);
>>  }
>>  
>>  static struct clnt_info *
>> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
>> index 565bce3..f4f5975 100644
>> --- a/utils/gssd/gssd.h
>> +++ b/utils/gssd/gssd.h
>> @@ -49,7 +49,7 @@
>>  #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
>>  #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
>>  #define GSSD_SERVICE_NAME			"nfs"
>> -
>> +#define RPC_CHAN_BUF_SIZE			32768
>>  /*
>>   * The gss mechanisms that we can handle
>>   */
>> @@ -85,8 +85,15 @@ struct clnt_info {
>>  	struct			sockaddr_storage addr;
>>  };
>>  
>> -void handle_krb5_upcall(struct clnt_info *clp);
>> -void handle_gssd_upcall(struct clnt_info *clp);
>> +struct clnt_upcall_info {
>> +	struct clnt_info 	*clp;
>> +	char			lbuf[RPC_CHAN_BUF_SIZE];
>> +	int			lbuflen;
>> +	uid_t			uid;
>> +};
>> +
>> +void handle_krb5_upcall(struct clnt_upcall_info *clp);
>> +void handle_gssd_upcall(struct clnt_upcall_info *clp);
>>  
>>  
>>  #endif /* _RPC_GSSD_H_ */
>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>> index afaaf9e..d74d372 100644
>> --- a/utils/gssd/gssd_proc.c
>> +++ b/utils/gssd/gssd_proc.c
>> @@ -79,7 +79,6 @@
>>  #include "nfsrpc.h"
>>  #include "nfslib.h"
>>  #include "gss_names.h"
>> -#include "misc.h"
>>  
>>  /* Encryption types supported by the kernel rpcsec_gss code */
>>  int num_krb5_enctypes = 0;
>> @@ -708,45 +707,22 @@ out_return_error:
>>  	goto out;
>>  }
>>  
>> -/* signal to the parent thread that we have read from the file descriptor.
>> - * it should allow the parent to proceed to poll on the descriptor for
>> - * the next upcall from the kernel.
>> - */
>> -static inline void
>> -signal_parent_event_consumed(void)
>> -{
>> -	pthread_mutex_lock(&pmutex);
>> -	thread_started = true;
>> -	pthread_cond_signal(&pcond);
>> -	pthread_mutex_unlock(&pmutex);
>> -}
>> -
>>  void
>> -handle_krb5_upcall(struct clnt_info *clp)
>> +handle_krb5_upcall(struct clnt_upcall_info *info)
>>  {
>> -	uid_t			uid;
>> -	int 			status;
>> +	struct clnt_info *clp = info->clp;
>>  
>> -	status = read(clp->krb5_fd, &uid, sizeof(uid)) < (ssize_t)sizeof(uid);
>> -	signal_parent_event_consumed();
>> +	printerr(2, "\n%s: uid %d (%s)\n", __func__, info->uid, clp->relpath);
>>  
>> -	if (status) {
>> -		printerr(0, "WARNING: failed reading uid from krb5 "
>> -			    "upcall pipe: %s\n", strerror(errno));
>> -		return;
>> -	}
>> -
>> -	printerr(2, "\n%s: uid %d (%s)\n", __func__, uid, clp->relpath);
>> -
>> -	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
>> +	process_krb5_upcall(clp, info->uid, clp->krb5_fd, NULL, NULL);
>> +	free(info);
>>  }
>>  
>>  void
>> -handle_gssd_upcall(struct clnt_info *clp)
>> +handle_gssd_upcall(struct clnt_upcall_info *info)
>>  {
>> +	struct clnt_info	*clp = info->clp;
>>  	uid_t			uid;
>> -	char			lbuf[RPC_CHAN_BUF_SIZE];
>> -	int			lbuflen = 0;
>>  	char			*p;
>>  	char			*mech = NULL;
>>  	char			*uidstr = NULL;
>> @@ -754,19 +730,9 @@ handle_gssd_upcall(struct clnt_info *clp)
>>  	char			*service = NULL;
>>  	char			*enctypes = NULL;
>>  
>> -	lbuflen = read(clp->gssd_fd, lbuf, sizeof(lbuf));
>> -	signal_parent_event_consumed();
>> +	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
>>  
>> -	if (lbuflen <= 0 || lbuf[lbuflen-1] != '\n') {
>> -		printerr(0, "WARNING: handle_gssd_upcall: "
>> -			    "failed reading request\n");
>> -		return;
>> -	}
>> -	lbuf[lbuflen-1] = 0;
>> -
>> -	printerr(2, "\n%s: '%s' (%s)\n", __func__, lbuf, clp->relpath);
>> -
>> -	for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
>> +	for (p = strtok(info->lbuf, " "); p; p = strtok(NULL, " ")) {
>>  		if (!strncmp(p, "mech=", strlen("mech=")))
>>  			mech = p + strlen("mech=");
>>  		else if (!strncmp(p, "uid=", strlen("uid=")))
>> @@ -782,8 +748,8 @@ handle_gssd_upcall(struct clnt_info *clp)
>>  	if (!mech || strlen(mech) < 1) {
>>  		printerr(0, "WARNING: handle_gssd_upcall: "
>>  			    "failed to find gss mechanism name "
>> -			    "in upcall string '%s'\n", lbuf);
>> -		return;
>> +			    "in upcall string '%s'\n", info->lbuf);
>> +		goto out;
>>  	}
>>  
>>  	if (uidstr) {
>> @@ -795,21 +761,21 @@ handle_gssd_upcall(struct clnt_info *clp)
>>  	if (!uidstr) {
>>  		printerr(0, "WARNING: handle_gssd_upcall: "
>>  			    "failed to find uid "
>> -			    "in upcall string '%s'\n", lbuf);
>> -		return;
>> +			    "in upcall string '%s'\n", info->lbuf);
>> +		goto out;
>>  	}
>>  
>>  	if (enctypes && parse_enctypes(enctypes) != 0) {
>>  		printerr(0, "WARNING: handle_gssd_upcall: "
>>  			 "parsing encryption types failed: errno %d\n", errno);
>> -		return;
>> +		goto out;
>>  	}
>>  
>>  	if (target && strlen(target) < 1) {
>>  		printerr(0, "WARNING: handle_gssd_upcall: "
>>  			 "failed to parse target name "
>> -			 "in upcall string '%s'\n", lbuf);
>> -		return;
>> +			 "in upcall string '%s'\n", info->lbuf);
>> +		goto out;
>>  	}
>>  
>>  	/*
>> @@ -823,8 +789,8 @@ handle_gssd_upcall(struct clnt_info *clp)
>>  	if (service && strlen(service) < 1) {
>>  		printerr(0, "WARNING: handle_gssd_upcall: "
>>  			 "failed to parse service type "
>> -			 "in upcall string '%s'\n", lbuf);
>> -		return;
>> +			 "in upcall string '%s'\n", info->lbuf);
>> +		goto out;
>>  	}
>>  
>>  	if (strcmp(mech, "krb5") == 0 && clp->servername)
>> @@ -835,5 +801,8 @@ handle_gssd_upcall(struct clnt_info *clp)
>>  				 "received unknown gss mech '%s'\n", mech);
>>  		do_error_downcall(clp->gssd_fd, uid, -EACCES);
>>  	}
>> +out:
>> +	free(info);
>> +	return;
>>  }
>>  
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
