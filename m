Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab0JMPMk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 11:12:40 -0400
Message-ID: <4CB5CC64.1060303@RedHat.com>
Date: Wed, 13 Oct 2010 11:12:36 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/15] mountd: Clear mountd registrations at start up
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000411.6667.17979.stgit@ellison.1015granger.net> <4CB5C876.3030203@RedHat.com>
In-Reply-To: <4CB5C876.3030203@RedHat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/13/2010 10:55 AM, Steve Dickson wrote:
> 
> 
> On 10/10/2010 08:04 PM, Chuck Lever wrote:
>> Clear stale MNT registrations before mountd tries to create fresh
>> listeners, to ensure that mountd starts.  This is also what statd
>> does.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  utils/mountd/mountd.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
>> index d309950..7e0cf6a 100644
>> --- a/utils/mountd/mountd.c
>> +++ b/utils/mountd/mountd.c
>> @@ -840,6 +840,7 @@ main(int argc, char **argv)
>>  	if (new_cache)
>>  		cache_open();
>>  
>> +	unregister_services();
>>  	if (version2()) {
>>  		listeners += nfs_svc_create("mountd", MOUNTPROG,
>>  					MOUNTVERS, mount_dispatch, port);
>>
> Question, since unregister_services() only unregisters version
> that are currently requested, won't it miss unregistering 
> version that are not currently requested, ones that are left over
> from a previous instant of mountd? 
> 
> The point being all versions need to be unregistered at his point, 
> not just the ones currently being requested. 
Something like:

mountd: Clear mountd registrations at start up

Clear stale MNT registrations before mountd tries to create fresh
listeners, to ensure that mountd starts.  This is also what statd
does.

Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index d309950..c36c471 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -97,13 +97,13 @@ static int version_any(void)
 }
 
 static void
-unregister_services (void)
+unregister_services (int all)
 {
-	if (version2()) {
+	if (all || version2()) {
 		nfs_svc_unregister(MOUNTPROG, MOUNTVERS);
 		nfs_svc_unregister(MOUNTPROG, MOUNTVERS_POSIX);
 	}
-	if (version3())
+	if (all || version3())
 		nfs_svc_unregister(MOUNTPROG, MOUNTVERS_NFSV3);
 }
 
@@ -180,7 +180,7 @@ fork_workers(void)
 
 	/* in parent */
 	wait_for_workers();
-	unregister_services();
+	unregister_services(0);
 	cleanup_lockfiles();
 	xlog(L_NOTICE, "mountd: no more workers, exiting\n");
 	exit(0);
@@ -192,7 +192,7 @@ fork_workers(void)
 static void 
 killer (int sig)
 {
-	unregister_services();
+	unregister_services(0);
 	if (num_threads > 1) {
 		/* play Kronos and eat our children */
 		kill(0, SIGTERM);
@@ -840,6 +840,7 @@ main(int argc, char **argv)
 	if (new_cache)
 		cache_open();
 
+	unregister_services(1);
 	if (version2()) {
 		listeners += nfs_svc_create("mountd", MOUNTPROG,
 					MOUNTVERS, mount_dispatch, port);
@@ -895,7 +896,7 @@ main(int argc, char **argv)
 	my_svc_run();
 
 	xlog(L_ERROR, "RPC service loop terminated unexpectedly. Exiting...\n");
-	unregister_services();
+	unregister_services(0);
 	exit(1);
 }
 

