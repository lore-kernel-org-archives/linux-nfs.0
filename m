Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab0IPLG3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 07:06:29 -0400
Message-ID: <4C91FA2C.3090105@RedHat.com>
Date: Thu, 16 Sep 2010 07:06:20 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>	<20100914092304.74c8aa34@corrin.poochiereds.net>	<4C9127DE.8050003@RedHat.com> <20100915183110.7d075052@tlielax.poochiereds.net>
In-Reply-To: <20100915183110.7d075052@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/15/2010 06:31 PM, Jeff Layton wrote:
> On Wed, 15 Sep 2010 16:09:02 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 09/14/2010 09:23 AM, Jeff Layton wrote:
>>> On Tue, 31 Aug 2010 15:32:40 -0400
>>> Jeff Layton <jlayton@redhat.com> wrote:
>>>
>>> Hi Steve,
>>>
>>> It's been a couple of weeks and this latest patch hasn't been committed...
>>>
>>> IIRC, you wanted changes to the xlog messages and were going to send an
>>> alternate patch. I'd like to see this in the next release of nfs-utils.
>>> What do we need to do to move this to resolution?
>> Sorry for taking so long to get to this..  
>>
>> What I was thinking is to simply make the error messages more definitive 
>> as to what the problem is and how to fix it.. Logging that we are 
>> falling back to the legacy probably would not mean much to mere 
>> mortals... IMHO... 
>>
>> I still think at some point nfsd should fail to start up, but logging
>> an error message at this point is fine..
>>
>> Comments?
>>
>> steved.
>>
>> commit 8a78cb2e651d55fc1aaacf1e4ca9c009d1cf9113
>> Author: Jeff Layton <jlayton@redhat.com>
>> Date:   Wed Sep 15 15:54:36 2010 -0400
>>
>>     rpc.nfsd: mount up nfsdfs is it doesn't appear to be mounted yet (try #3)
>>     
>>     There's a bit of a chicken and egg problem when nfsd is run the first
>>     time. On Fedora/RHEL at least, /proc/fs/nfsd is mounted up whenever nfsd
>>     is plugged in via a modprobe.conf "install" directive.
>>     
>>     If someone runs rpc.nfsd without plugging in nfsd.ko first,
>>     /proc/fs/nfsd won't be mounted and rpc.nfsd will end up using the legacy
>>     nfsctl interface. After that, nfsd will be plugged in and subsequent
>>     rpc.nfsd invocations will use that instead.
>>     
>>     This is a problem as some nfsd command-line options are ignored when the
>>     legacy interface is used. It'll also be a problem for people who want
>>     IPv6 enabled servers. The upshot is that we really don't want to use the
>>     legacy interface unless there is no other option.
>>     
>>     To avoid this situation, have rpc.nfsd check to see if the "threads"
>>     file is already present. If it's not, then make an attempt to mount
>>     /proc/fs/nfsd.  This is a "best-effort" sort of thing, however so we
>>     just ignore the return code from the mount attempt and fall back to
>>     using nfsctl() if it fails.
>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>> index 1cda1e5..658b8fa 100644
>> --- a/utils/nfsd/nfsd.c
>> +++ b/utils/nfsd/nfsd.c
>> @@ -246,6 +246,9 @@ main(int argc, char **argv)
>>  		exit(1);
>>  	}
>>  
>> +	/* make sure nfsdfs is mounted if it's available */
>> +	nfssvc_mount_nfsdfs(progname);
>> +
>>  	/* can only change number of threads if nfsd is already up */
>>  	if (nfssvc_inuse()) {
>>  		socket_up = 1;
>> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
>> index 34c67ca..f7edcba 100644
>> --- a/utils/nfsd/nfssvc.c
>> +++ b/utils/nfsd/nfssvc.c
>> @@ -15,9 +15,11 @@
>>  #include <netdb.h>
>>  #include <netinet/in.h>
>>  #include <arpa/inet.h>
>> +#include <sys/stat.h>
>>  #include <unistd.h>
>>  #include <fcntl.h>
>>  #include <errno.h>
>> +#include <stdlib.h>
>>  
>>  #include "nfslib.h"
>>  #include "xlog.h"
>> @@ -31,9 +33,13 @@
>>   */
>>  #undef IPV6_SUPPORTED
>>  
>> -#define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
>> -#define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
>> -#define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
>> +#ifndef NFSD_FS_DIR
>> +#define NFSD_FS_DIR	  "/proc/fs/nfsd"
>> +#endif
>> +
>> +#define NFSD_PORTS_FILE   NFSD_FS_DIR "/portlist"
>> +#define NFSD_VERS_FILE    NFSD_FS_DIR "/versions"
>> +#define NFSD_THREAD_FILE  NFSD_FS_DIR "/threads"
>>  
>>  /*
>>   * declaring a common static scratch buffer here keeps us from having to
>> @@ -44,6 +50,45 @@
>>  char buf[128];
>>  
>>  /*
>> + * Using the "new" interfaces for nfsd requires that /proc/fs/nfsd is
>> + * actually mounted. Make an attempt to mount it here if it doesn't appear
>> + * to be. If the mount attempt fails, no big deal -- fall back to using nfsctl
>> + * instead.
>> + */
>> +void
>> +nfssvc_mount_nfsdfs(char *progname)
>> +{
>> +	int err;
>> +	struct stat statbuf;
>> +
>> +	err = stat(NFSD_THREAD_FILE, &statbuf);
>> +	if (err == 0)
>> +		return;
>> +	else if (errno != ENOENT) {
>> +		xlog(L_ERROR, "Unable to stat %s: errno %d (%m)",
>> +				NFSD_THREAD_FILE, errno);
>> +		return;
>> +	}
>> +
>> +	/*
>> +	 * this call can return an error if modprobe is set up to automatically
>> +	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
>> +	 * code from it and just check for the "threads" file afterward.
>> +	 */
>> +	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
>> +
>> +	err = stat(NFSD_THREAD_FILE, &statbuf);
>> +	if (err == 0)
>> +		return;
>> +
>> +	xlog(L_ERROR, "Unable to access " NFSD_FS_DIR " errno %d (%m)." 
>> +		"\nPlease try, as root, 'mount -t nfsd nfsd " NFSD_FS_DIR 
>> +		"' and then restart %s to correct the problem", errno, progname);
>> +
> 
> A few of problems with that log message...
> 
> First, it looks like something failed, but nfsd will probably end up
> getting started anyway. We recommend starting nfsd to correct the
> problem, but it's not clear what the problem actually is. nfsd got
> started right?
Hmm... I was thinking this part of the message
    "Unable to access " NFSD_FS_DIR " errno %d (%m)."
made it clear as to what the problem is. 

We are making note of a non fatal error... and since
the message is being written to stderr, instead if 
syslog()-ed, the actual message look more like a note 
then an error since the 'ERROR' string is not be added.
We could change the message to a L_WARNING... 

> 
> Second, it says to restart nfsd to correct the problem, but restarting
> nfsd isn't exactly straightforward (you need to run "nfsd 0" and then
> nfsd <some positive int>).
Well I'm making the assumption that people who do see this
message did not use the normal init-script way of starting rpc.nfsd,
because if they did they would not be seeing this message. So,
again I'm assuming, that these same people are starting rpc.nfsd
my hand, which means they know how to restart rpc.nfsd.

> 
> Third, there could be other problems than just the fact that nfsdfs
> didn't get mounted. Maybe there was some weird SELinux permissions
> problem? In that case, trying to mount nfsdfs won't help anything and
> that message will just confuse the issue.
If its an SELinux error or some issue that causing either the stat()
and mount() to fail, hopefully those type of issues will be logged. 
Plus having them try the mount by hand could possibly lead them in the 
right direction.

> 
> I think it's going to be really difficult to explain the problem and
> solution in a terse xlog message. My expectation was mainly that we
> should pop up a message to give the user a heads up that "something" is
> wrong. I think it's tough to offer specific solutions in such a message
> though.
All I'm trying to is log an non-fatal error,  give a reason
as to why the error happen and a possible resolution to that error.
Since were are not logging the fact the system() call failed, I
thought it was a fairly reasonable thing to do....


steved.
