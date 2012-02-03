Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:36103 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755786Ab2BCKTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 05:19:19 -0500
Message-ID: <4F2BB2C0.9060207@st.com>
Date: Fri, 03 Feb 2012 10:11:12 +0000
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Reply-To: srinivas.kandagatla@st.com
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
Cc: srinivas.kandagatla@st.com, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com, bharrosh@panasas.com, rees@umich.edu,
        linux@razik.name
Subject: Re: [PATCH 3.3.0-rc1 1/2] do_mounts: Change the nfs-mount retry min
 max delays.
References: <1327588962-16441-1-git-send-email-srinivas.kandagatla@st.com> <EBFEB6A8-4943-4D9E-9139-73D14ACB32DD@oracle.com> <4F225BED.7000005@st.com>
In-Reply-To: <4F225BED.7000005@st.com>
Content-Type: multipart/mixed;
 boundary="------------020106040207090805010907"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020106040207090805010907
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Chuck,

Am resending patch with modifications to retries to compensate the total
delay as it is currently there.

As I said in my previous email... intention of the patch is to address most of the use-cases.


Thanks
srini

Srinivas Kandagatla wrote:
> Chuck Lever wrote:
>> On Jan 26, 2012, at 9:42 AM, Srinivas KANDAGATLA wrote:
>>
>>   
>>> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>>
>>> This patch attempts to minimize the delay in nfs root mount, which
>>> happens as side effect of nfs-root mount retry by changing the
>>> NFSROOT_TIMEOUT_MIN and NFSROOT_TIMEOUT_MAX values.
>>>
>>> Current strategy is, if do_mount_root fails, sleep for 5 seconds for the
>>> second attempt followed by a 5<<1 seconds delay for each loop with a
>>> maximum of 30 seconds delay.
>>> For 5 retries it would take.
>>>
>>> 	5 + 10 + 20 + 30 + 30 = 95 Seconds
>>> with
>>> 	each do_mount_root timeout @ 3-4 seconds x 5 = 15 seconds.
>>>
>>> Which means Kernel can only attempt the succession root-mounts or panic
>>> after 110 seconds.
>>>
>>> So changing min and max timeouts will have the below delays.
>>> 	0  + 1 + 3 + 7 + 15	= 26 Seconds.
>>> and with
>>> 	each do_mount_root timeout @ 3-4 seconds x 5 = 15 seconds.
>>> Which means Kernel can only attempt the succession root-mounts or panic
>>> after 41 seconds
>>>
>>> As, do_mount_root timesout in 3-4 seconds which should be sufficient
>>> delay to start of the second nfs mount attempt and increasing delay
>>> after that makes more sense.
>>>
>>> I clearly see an advantange in changing these values because, Without
>>> this patch my board mounts nfs in 9-10 seconds, however with this patch
>>> can mount nfs in 4-5 seconds.
>>>     
>> This feels like tuning the default settings for a very specific set up.  In the original thread for this work, 41 seconds would probably not be long enough for the network switch to enable the port.
>>   
> Probably you might be right.
> We could address that by increasing NFSROOT_RETRY_MAX to 7 from 5.
>
> However, I want to highlight an another major issue of having an min
> timeout start at 5.
> Most of the boards (or SOC's) have in-build ethernet MAC's and external
> Ethernet PHY's, Linux PHY (& phy state-machine) framework takes on an
> average of 2-3 seconds from phy_start to get the ethernet PHY into a
> Link-up state.
> All those above boards which used to mount NFS in 3-4 seconds prior to
> the original "NFS: Retry mounting NFSROOT" patch and few other patches,
> NOW mounts NFS root in 9-10 seconds.
> Which is the case with all the ST boards and most of the embedded boards
> with external PHY's fall in.
>
> Having the timeout start from 0 will address the uses case mentioned
> above and increasing the loops from 5 to 8 will increase the total NFS
> root timeout to 109 seconds.
>
> 0  + 1 + 3 + 7 + 15 + 31 + 31  = 88
>  + 
> each do_mount_root timeout @ 3-4 seconds x 7 = 21 = 109 seconds
>
>
> Finally the intention of the patch was to address most of the use-cases
> and not just the one I hit, increasing the retries to 7 should address
> the orignal network switch case and reducing the timeout-min should help
> other boards do nfs mounts as quickly as it used to happen before.
>
> Let me know if this sounds OK to you so that I can generate a new patch?
>
>
>
> Thanks,
> srini
>> I don't have a better solution at this time, but I think the current defaults will work (possibly with added delay) on most systems, whereas the proposed settings will probably result in more panics.  I prefer to keep the current settings until we have a solution that doesn't break other systems.
>>
>>   
>>> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>> ---
>>> Hello All,
>>> With latest kernel I can see that my nfs-root mounts with big delay
>>> of 5 seconds when compared to 2.6.32. It took 9-10 seconds, where as in 2.6.32 it took 4-5 seconds.
>>>
>>> However with modifications to NFSROOT_TIMEOUT_MIN and NFSROOT_TIMEOUT_MAX,  nfs root mounts as it used to do it in 2.6.32.
>>> As first nfs mount timeout itself introduces sufficient delay to start the second retry.
>>> I think changing the min-max values will help people to nfs boot there boards faster than it is in 3.3 kernel.
>>>
>>> Comments ?
>>>
>>> Thanks.
>>> srini
>>>
>>>
>>>
>>> init/do_mounts.c |    6 +++---
>>> 1 files changed, 3 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/init/do_mounts.c b/init/do_mounts.c
>>> index ef6478f..b8214ce 100644
>>> --- a/init/do_mounts.c
>>> +++ b/init/do_mounts.c
>>> @@ -361,8 +361,8 @@ out:
>>>
>>> #ifdef CONFIG_ROOT_NFS
>>>
>>> -#define NFSROOT_TIMEOUT_MIN	5
>>> -#define NFSROOT_TIMEOUT_MAX	30
>>> +#define NFSROOT_TIMEOUT_MIN	1
>>> +#define NFSROOT_TIMEOUT_MAX	32
>>> #define NFSROOT_RETRY_MAX	5
>>>
>>> static int __init mount_nfs_root(void)
>>> @@ -390,7 +390,7 @@ static int __init mount_nfs_root(void)
>>> 			break;
>>>
>>> 		/* Wait, in case the server refused us immediately */
>>> -		ssleep(timeout);
>>> +		ssleep(timeout - 1);
>>> 		timeout <<= 1;
>>> 		if (timeout > NFSROOT_TIMEOUT_MAX)
>>> 			timeout = NFSROOT_TIMEOUT_MAX;
>>> -- 
>>> 1.6.3.3
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>     
>>   
>
>


--------------020106040207090805010907
Content-Type: text/x-patch;
 name="0001-do_mounts-Change-the-nfs-mount-retry-min-max-delays.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-do_mounts-Change-the-nfs-mount-retry-min-max-delays.pat";
 filename*1="ch"

>From d5f9ca4e677346e0659ddfc30608adc6cc39312e Mon Sep 17 00:00:00 2001
From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Date: Fri, 3 Feb 2012 10:02:46 +0000
Subject: [PATCH 3.3.0-rc1] do_mounts: Change the nfs-mount retry min max delays.

This patch attempts to minimize the delay in nfs root mount, which
happens as side effect of nfs-root mount retry by changing the
NFSROOT_TIMEOUT_MIN, NFSROOT_TIMEOUT_MAX and NFSROOT_RETRY_MAX values.

Current strategy is, if do_mount_root fails, sleep for 5 seconds for the
second attempt followed by a 5<<1 seconds delay for each loop with a
maximum of 30 seconds delay.
For 5 retries it would take.

        5 + 10 + 20 + 30 + 30 = 95 Seconds
with
        each do_mount_root timeout @ 3-4 seconds x 5 = 15 seconds.

Starting with sleep of 5 seconds introduces an delay of 5 seconds in
nfs-mount time in the below cases.

Most of the boards (or SOC's) have in-build ethernet MAC's and external
Ethernet PHY's, Linux PHY (& phy state-machine) framework takes on an
average of 2-3 seconds from phy_start to get the ethernet PHY into a
Link-up state.

All those above boards which used to mount NFS in 3-4 seconds prior to
commit  43717c7d, "NFS: Retry mounting NFSROOT" and 56463e50 "NFS:Use
super.c for NFSROOT mount option parsing" patches, NOW mounts NFS root
in 9-10 seconds.
Which is the case with all the STMicroelectronics boards and I think
most of the embedded boards have external PHY's.

Having the timeout start from 0 will address the usecase mentioned
above and increasing the loops from 5 to 7 will increase the total NFS
root timeout to 109 seconds (as it currently there).

0  + 1 + 3 + 7 + 15 + 31 + 31  = 88
 +
each do_mount_root timeout @ 3-4 seconds x 7 = 21 = 109 seconds

What we are trying to achieve here is, same behaviour which used to be
there before those two commits

As, do_mount_root timesout in 3-4 seconds which should be sufficient
delay to start of the second nfs mount attempt and progressively
increasing delay after that makes more sense.

I clearly see an advantange in changing these values because, Without
this patch my board mounts nfs in 9-10 seconds, however with this patch
can mount nfs in 4-5 seconds.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 init/do_mounts.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/init/do_mounts.c b/init/do_mounts.c
index ef6478f..cad1366 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -361,9 +361,9 @@ out:
  
 #ifdef CONFIG_ROOT_NFS
 
-#define NFSROOT_TIMEOUT_MIN	5
-#define NFSROOT_TIMEOUT_MAX	30
-#define NFSROOT_RETRY_MAX	5
+#define NFSROOT_TIMEOUT_MIN	1
+#define NFSROOT_TIMEOUT_MAX	32
+#define NFSROOT_RETRY_MAX	7
 
 static int __init mount_nfs_root(void)
 {
@@ -390,7 +390,7 @@ static int __init mount_nfs_root(void)
 			break;
 
 		/* Wait, in case the server refused us immediately */
-		ssleep(timeout);
+		ssleep(timeout - 1);
 		timeout <<= 1;
 		if (timeout > NFSROOT_TIMEOUT_MAX)
 			timeout = NFSROOT_TIMEOUT_MAX;
-- 
1.6.3.3


--------------020106040207090805010907--
