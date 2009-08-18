Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:36984 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757747AbZHRNTD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 09:19:03 -0400
Cc: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Message-Id: <82BFE5F7-0975-44AA-A44D-E0E768FE3722@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Ian Kent <ikent@redhat.com>
In-Reply-To: <1250555418.16878.7.camel@zeus.themaw.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; delsp=yes
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Tue, 18 Aug 2009 09:17:58 -0400
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com> <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com> <f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com> <7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com> <4A82CE18.6020401@redhat.com> <f6ce31e30908120800i2cc82005s695d1097df554b58@mail.gmail.com> <4A82DDB1.1000109@redhat.com> <f6ce31e30908120940m6e9a093ayc59d7ef98e37b3d0@mail.gmail.com> <4A84210F.3020906@redhat.com> <f6ce31e30908130743l78423b52je5aaeaaf3ed1a373@mail.gmail.com> <f6ce31e30908130818r2ccd676ax174eb5062282a15b@mail.gmail.com> <1250555418.16878.7.camel@zeus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug 17, 2009, at 8:30 PM, Ian Kent wrote:
> On Thu, 2009-08-13 at 12:18 -0300, Carlos André wrote:
>> Filled bug report:
>> https://bugzilla.redhat.com/show_bug.cgi?id=517349
>
> Hi Carlos,
>
> I have a patched source rpm to add a mount wait parameter to autofs
> located at:
> http://people.redhat.com/~ikent/autofs-5.0.1-0.rc2.131.bz517349.1
>
> Could you build it and see if it works.
> I haven't tested it at all but it is fairly straight forward.

For NFSv2/v3, we have an rpcbind query followed by a MNT request, on  
separate transports that the kernel can set up with fast timeouts  
(when the underlying transport implementations eventually support this).

It could be more challenging for NFSv4 because the initial connection  
is done on the same NFS transport that will be used for normal  
operation.  The connection timeout parameters can't easily be changed  
from giving up quickly to normal, at least with the current RPC  
infrastructure.  Perhaps the first few NFSv4 operations could be done  
on a separate transport.

> It is still unclear if this is the right way to do this and what the
> consequences are in sending a term signal to mount. This mount request
> will likely be followed by other requests for the same mount causing  
> an
> accumulation of mount(8) processes waiting for RPC timeouts before  
> they
> can answer the TERM signal.

One concern is that this would leave a number of outgoing privileged  
ports in use (until the mount attempts time out, then after another  
two minutes the port leaves TIME_WAIT).  Clearly we need an in-kernel  
solution to canceling mount requests without leaving a bunch of  
resources tied up.  Probably the best approach, in general terms, is  
to tell mount(2) how long to wait, then let the kernel abort it as  
needed.

> Anyway, for information the patch included in the source rpm above is:
>
> autofs-5.0.4 - add mount wait parameter
>
> From: Ian Kent <raven@themaw.net>
>
> Often delays when trying to mount from a server that is not reponding
> for some reason are undesirable. To try and prevent these delays we
> provide a configuration setting to limit the time that we wait for
> our spawned mount(8) process to complete before sending it a SIGTERM
> signal. This patch adds a configuration parameter to allow us to
> request we limit the time we wait for mount(8) to complete before
> send it a TERM signal.
> ---
>
> daemon/spawn.c                 |    3 ++-
> include/defaults.h             |    2 ++
> lib/defaults.c                 |   13 +++++++++++++
> man/auto.master.5.in           |    7 +++++++
> redhat/autofs.sysconfig.in     |    9 +++++++++
> samples/autofs.conf.default.in |    9 +++++++++
> 6 files changed, 42 insertions(+), 1 deletion(-)
>
>
> --- autofs-5.0.1.orig/daemon/spawn.c
> +++ autofs-5.0.1/daemon/spawn.c
> @@ -312,6 +312,7 @@ int spawn_mount(unsigned logopt, ...)
> 	unsigned int options;
> 	unsigned int retries = MTAB_LOCK_RETRIES;
> 	int update_mtab = 1, ret, printed = 0;
> +	unsigned int wait = defaults_get_mount_wait();
> 	char buf[PATH_MAX];
>
> 	/* If we use mount locking we can't validate the location */
> @@ -353,7 +354,7 @@ int spawn_mount(unsigned logopt, ...)
> 	va_end(arg);
>
> 	while (retries--) {
> -		ret = do_spawn(logopt, -1, options, prog, (const char **) argv);
> +		ret = do_spawn(logopt, wait, options, prog, (const char **) argv);
> 		if (ret & MTAB_NOTUPDATED) {
> 			struct timespec tm = {3, 0};
>
> --- autofs-5.0.1.orig/include/defaults.h
> +++ autofs-5.0.1/include/defaults.h
> @@ -24,6 +24,7 @@
>
> #define DEFAULT_TIMEOUT			600
> #define DEFAULT_NEGATIVE_TIMEOUT	60
> +#define DEFAULT_MOUNT_WAIT		-1
> #define DEFAULT_UMOUNT_WAIT		12
> #define DEFAULT_BROWSE_MODE		1
> #define DEFAULT_LOGGING			0
> @@ -62,6 +63,7 @@ struct ldap_schema *defaults_get_schema(
> struct ldap_searchdn *defaults_get_searchdns(void);
> void defaults_free_searchdns(struct ldap_searchdn *);
> unsigned int defaults_get_append_options(void);
> +unsigned int defaults_get_mount_wait(void);
> unsigned int defaults_get_umount_wait(void);
> const char *defaults_get_auth_conf_file(void);
> unsigned int defaults_get_map_hash_table_size(void);
> --- autofs-5.0.1.orig/lib/defaults.c
> +++ autofs-5.0.1/lib/defaults.c
> @@ -45,6 +45,7 @@
> #define ENV_NAME_VALUE_ATTR		"VALUE_ATTRIBUTE"
>
> #define ENV_APPEND_OPTIONS		"APPEND_OPTIONS"
> +#define ENV_MOUNT_WAIT			"MOUNT_WAIT"
> #define ENV_UMOUNT_WAIT			"UMOUNT_WAIT"
> #define ENV_AUTH_CONF_FILE		"AUTH_CONF_FILE"
>
> @@ -323,6 +324,7 @@ unsigned int defaults_read_config(unsign
> 		    check_set_config_value(key, ENV_NAME_ENTRY_ATTR, value,  
> to_syslog) ||
> 		    check_set_config_value(key, ENV_NAME_VALUE_ATTR, value,  
> to_syslog) ||
> 		    check_set_config_value(key, ENV_APPEND_OPTIONS, value,  
> to_syslog) ||
> +		    check_set_config_value(key, ENV_MOUNT_WAIT, value, to_syslog)  
> ||
> 		    check_set_config_value(key, ENV_UMOUNT_WAIT, value, to_syslog)  
> ||
> 		    check_set_config_value(key, ENV_AUTH_CONF_FILE, value,  
> to_syslog) ||
> 		    check_set_config_value(key, ENV_MAP_HASH_TABLE_SIZE, value,  
> to_syslog))
> @@ -652,6 +654,17 @@ unsigned int defaults_get_append_options
> 	return res;
> }
>
> +unsigned int defaults_get_mount_wait(void)
> +{
> +	long wait;
> +
> +	wait = get_env_number(ENV_MOUNT_WAIT);
> +	if (wait < 0)
> +		wait = DEFAULT_MOUNT_WAIT;
> +
> +	return (unsigned int) wait;
> +}
> +
> unsigned int defaults_get_umount_wait(void)
> {
> 	long wait;
> --- autofs-5.0.1.orig/man/auto.master.5.in
> +++ autofs-5.0.1/man/auto.master.5.in
> @@ -175,6 +175,13 @@ Set the default timeout for caching fail
> 60). If the equivalent command line option is given it will override  
> this
> setting.
> .TP
> +.B MOUNT_WAIT
> +Set the default time to wait for a response from a spawned mount(8)
> +before sending it a SIGTERM. Note that we still need to wait for the
> +RPC layer to timeout before the sub-process exits so this isn't ideal
> +but it is the best we can do. The default is to wait until mount(8)
> +returns without intervention.
> +.TP
> .B UMOUNT_WAIT
> Set the default time to wait for a response from a spawned umount(8)
> before sending it a SIGTERM. Note that we still need to wait for the
> --- autofs-5.0.1.orig/redhat/autofs.sysconfig.in
> +++ autofs-5.0.1/redhat/autofs.sysconfig.in
> @@ -14,6 +14,15 @@ TIMEOUT=300
> #
> #NEGATIVE_TIMEOUT=60
> #
> +# MOUNT_WAIT - time to wait for a response from umount(8).
> +# 	       Setting this timeout can cause problems when
> +# 	       mount would otherwise wait for a server that
> +# 	       is temporarily unavailable, such as when it's
> +# 	       restarting. The defailt of waiting for mount(8)
> +# 	       usually results in a wait of around 3 minutes.
> +#
> +#MOUNT_WAIT=-1
> +#
> # UMOUNT_WAIT - time to wait for a response from umount(8).
> #
> #UMOUNT_WAIT=12
> --- autofs-5.0.1.orig/samples/autofs.conf.default.in
> +++ autofs-5.0.1/samples/autofs.conf.default.in
> @@ -14,6 +14,15 @@ TIMEOUT=300
> #
> #NEGATIVE_TIMEOUT=60
> #
> +# MOUNT_WAIT - time to wait for a response from umount(8).
> +# 	       Setting this timeout can cause problems when
> +# 	       mount would otherwise wait for a server that
> +# 	       is temporarily unavailable, such as when it's
> +# 	       restarting. The defailt of waiting for mount(8)
> +# 	       usually results in a wait of around 3 minutes.
> +#
> +#MOUNT_WAIT=-1
> +#
> # UMOUNT_WAIT - time to wait for a response from umount(8).
> #
> #UMOUNT_WAIT=12
>
>
>>
>> Thanks!
>>
>> 2009/8/13 Carlos André <candrecn@gmail.com>:
>>> 2009/8/13 Ian Kent <ikent@redhat.com>:
>>>> Carlos André wrote:
>>>>> Today (2009-08-12) I'm using:
>>>>> kernel-2.6.18-128.2.1.el5
>>>>> autofs-5.0.1-0.rc2.102.el5_3.1
>>>>
>>>> Thanks,
>>>>
>>>> My mistake, the wait time I was referring to is used for umounts  
>>>> during
>>>> expires and is present in rev rc2.102.
>>>>
>>>> It shouldn't be hard to add this for mount as well.
>>>> Would you like me to put something together?
>>>
>>> Sure! that 'll help me a lot (and for sure another ppl) :) Thanks :)
>>>
>>>>
>>>> Probably would be good to test something out to see if we can  
>>>> make a
>>>> difference with the killing mount after some configured timeout  
>>>> but, if
>>>> we make progress, probably the best way to deal with it is for  
>>>> you to
>>>> log a bug against rhel-5 so I can get it committed to the rhel  
>>>> package.
>>>> The possible issue is that I'm not sure if the RPC subsystem in the
>>>> above rhel kernel will respond well to process death with potential
>>>> outstanding requests. But we'll see.
>>>
>>> Ok, on my way :)
>>>
>>> Thanks a lot!
>>>
>>>>
>>>>>
>>>>>
>>>>> Look my last test:
>>>>> --------------------------------------------------------------
>>>>> [root@KSTATION areas]# time ls testdown
>>>>> ls: testdown: No such file or directory
>>>>>
>>>>> real    3m9.025s
>>>>> user    0m0.000s
>>>>> sys     0m0.002s
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: sun_mount: parse(sun):
>>>>> mounting root /misc/areas, mountpoint testdown, what
>>>>> 1.2.3.4:/areas/testdown, fstype nfs4, options
>>>>> acl,sec=krb5p,proto=tcp,retry=0
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: do_mount:
>>>>> 1.2.3.4:/areas/testdown /misc/areas/testdown type nfs4 options
>>>>> acl,sec=krb5p,proto=tcp,retry=0 using module nfs4
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount:  
>>>>> mount(nfs):
>>>>> root=/misc/areas name=testdown what=1.2.3.4:/areas/testdown,
>>>>> fstype=nfs4, options=acl,sec=krb5p,proto=tcp,retry=0
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount:  
>>>>> mount(nfs):
>>>>> nfs options="acl,sec=krb5p,proto=tcp,retry=0", nosymlink=0, ro=0
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount:  
>>>>> mount(nfs):
>>>>> calling mkdir_path /misc/areas/testdown
>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount:  
>>>>> mount(nfs):
>>>>> calling mount -t nfs4 -s -o acl,sec=krb5p,proto=tcp,retry=0
>>>>> 1.2.3.4:/areas/testdown /misc/areas/testdown
>>>>> Aug 12 12:58:12 KSTATION automount[15471]: st_expire: state 1  
>>>>> path /misc
>>>>> Aug 12 12:58:12 KSTATION automount[15471]: expire_proc: exp_proc =
>>>>> 3078093712 path /misc
>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_proc_indirect: 2
>>>>> submounts remaining in /misc
>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup: got  
>>>>> thid
>>>>> 3078093712 path /misc stat 3
>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup:  
>>>>> sigchld:
>>>>> exp 3078093712 finished, switching from 2 to 1
>>>>> Aug 12 12:58:13 KSTATION automount[15471]: st_ready: st_ready():  
>>>>> state
>>>>> = 2 path /misc
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: st_expire: state 1  
>>>>> path /misc
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc: exp_proc =
>>>>> 3078093712 path /misc
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc_indirect: 2
>>>>> submounts remaining in /misc
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup: got  
>>>>> thid
>>>>> 3078093712 path /misc stat 3
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup:  
>>>>> sigchld:
>>>>> exp 3078093712 finished, switching from 2 to 1
>>>>> Aug 12 12:59:28 KSTATION automount[15471]: st_ready: st_ready():  
>>>>> state
>>>>> = 2 path /misc
>>>>> Aug 12 13:00:16 KSTATION automount[15471]: >> mount: mount to NFS
>>>>> server '1.2.3.4' failed: timed out (giving up).
>>>>> Aug 12 13:00:16 KSTATION automount[15471]: mount(nfs): nfs: mount
>>>>> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
>>>>> Aug 12 13:00:16 KSTATION automount[15471]: send_fail: token = 17
>>>>> Aug 12 13:00:16 KSTATION automount[15471]: failed to mount /misc/ 
>>>>> areas/testdown
>>>>> Aug 12 13:00:43 KSTATION automount[15471]: st_expire: state 1  
>>>>> path /misc
>>>>> --------------------------------------------------------------
>>>>>
>>>>> 2009/8/12 Ian Kent <ikent@redhat.com>:
>>>>>> Carlos André wrote:
>>>>>>> Hi Ian,
>>>>>>> I'm getting crazy trying put "retry=" to work on mount... this  
>>>>>>> option
>>>>>>> just DONT WORK if use proto=tcp and/OR kerberos (sec=krb5/ 
>>>>>>> krb5i/krb5p)
>>>>>>> like you can see on my previous emails...
>>>>>> Right, my mistake for not looking closely enough at post.
>>>>>>
>>>>>> Maybe this is related to the same sort of problem we had with  
>>>>>> mount in
>>>>>> the past, before the options parsing went into the kernel,  
>>>>>> where other
>>>>>> services, like portmapper (or rpcbind), were being done with  
>>>>>> different
>>>>>> timeout parameters before the RPC calls for mounting. That's  
>>>>>> just an
>>>>>> example as NFSv4 shouldn't be sensitive to portmapper anyway.
>>>>>>
>>>>>> But what version of autofs and kernel did you say you were using?
>>>>>>
>>>>>>> I appreciate any help.
>>>>>>>
>>>>>>> Carlos.
>>>>>>>
>>>>>>>
>>>>>>> 2009/8/12 Ian Kent <ikent@redhat.com>:
>>>>>>>> Chuck Lever wrote:
>>>>>>>>> On Aug 11, 2009, at 8:41 AM, Carlos André wrote:
>>>>>>>>>> This long timeout is good if workstation need mount a  
>>>>>>>>>> critical
>>>>>>>>>> directory using /etc/fstab on boot (for example)..
>>>>>>>>>> But in my case, using this loooong timeout doesnt make any  
>>>>>>>>>> sense,
>>>>>>>>>> since autofs retry mount directory on-access. This in fact  
>>>>>>>>>> gives me
>>>>>>>>>> alot of headaches, coz user login 'll just hangs if one  
>>>>>>>>>> server goes
>>>>>>>>>> down for any reason, and will again hangs if user try  
>>>>>>>>>> access directory
>>>>>>>>>> pointing to a NFS down server...
>>>>>>>>> "retry=0" means the mount command will fail as soon as the  
>>>>>>>>> first
>>>>>>>>> mount(2) system call fails.  When you set SYN retries to 1,  
>>>>>>>>> this means
>>>>>>>>> after 9 seconds, the connect fails, and that causes the  
>>>>>>>>> mount(2) system
>>>>>>>>> call to fail.
>>>>>>>>>
>>>>>>>>> Recent conversations with Ian suggested that a long timeout  
>>>>>>>>> was desired
>>>>>>>>> for automounter as well as other cases.  Ian, is there  
>>>>>>>>> something else we
>>>>>>>>> need to consider to determine the correct retry timeout for  
>>>>>>>>> NFS/TCP
>>>>>>>>> mount points handled via automounter?  How should mount.nfs  
>>>>>>>>> wait so we
>>>>>>>>> don't make other use cases worse?  (Looks like most of the  
>>>>>>>>> history is
>>>>>>>>> intact below).
>>>>>>>> Of course we know that autofs is entirely at the mercy of  
>>>>>>>> mount(8) (and
>>>>>>>> mount.nfs in particular). This has always been a difficult  
>>>>>>>> situation for
>>>>>>>> the automounter because interactive mount invocations should  
>>>>>>>> wait. But I
>>>>>>>> believe automount mounts should always time out quickly, but  
>>>>>>>> that leads
>>>>>>>> to its own set of problems, especially when home directories  
>>>>>>>> are concerned.
>>>>>>>>
>>>>>>>> I think adding "retry=0" is the right thing to do myself but  
>>>>>>>> I'm not
>>>>>>>> certain that will work as we expect. I'll have to do some  
>>>>>>>> experimentation.
>>>>>>>>
>>>>>>>>> How long do you think is appropriate for the automounter to  
>>>>>>>>> wait if the
>>>>>>>>> server is down, in your case, Carlos?
>>>>>>>>>
>>>>>>>>>> Am losing something or there have was something weirdo...!?
>>>>>>>>>> ------------------------------------------------
>>>>>>>>>> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/ 
>>>>>>>>>> tcp_syn_retries  [DEFAULT]
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> proto=tcp,retry=1
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    3m9.000s
>>>>>>>>>> user    0m0.002s
>>>>>>>>>> sys     0m0.001s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> sec=krb5p,proto=tcp,retry=1
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    3m9.000s
>>>>>>>>>> user    0m0.000s
>>>>>>>>>> sys     0m0.002s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> proto=tcp,retry=0
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    3m9.001s
>>>>>>>>>> user    0m0.000s
>>>>>>>>>> sys     0m0.003s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> sec=krb5p,proto=tcp,retry=0
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    3m9.001s
>>>>>>>>>> user    0m0.002s
>>>>>>>>>> sys     0m0.001s
>>>>>>>>>>
>>>>>>>>>> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/ 
>>>>>>>>>> tcp_syn_retries [ 5 to 1 ]
>>>>>>>>>>
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> proto=tcp,retry=1
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (retrying). [x 6]
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    1m3.002s
>>>>>>>>>> user    0m0.000s
>>>>>>>>>> sys     0m0.002s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> sec=krb5p,proto=tcp,retry=1
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (retrying). [x 13]
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    2m6.000s
>>>>>>>>>> user    0m0.000s
>>>>>>>>>> sys     0m0.002s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> proto=tcp,retry=0
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    0m9.003s
>>>>>>>>>> user    0m0.001s
>>>>>>>>>> sys     0m0.002s
>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4  
>>>>>>>>>> -o
>>>>>>>>>> sec=krb5p,proto=tcp,retry=0
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (retrying). [x 13]
>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>> (giving up).
>>>>>>>>>>
>>>>>>>>>> real    2m6.001s
>>>>>>>>>> user    0m0.001s
>>>>>>>>>> sys     0m0.002s
>>>>>>>>>> [root@KSTATION ~]#
>>>>>>>>>> ------------------------------------------------
>>>>>>>>>> max timeout goes to 2m6s changing tcp_syn_retries from 5 to  
>>>>>>>>>> 1... and
>>>>>>>>>> using retry=0 without kerberos I got only 9s...
>>>>>>>>>>
>>>>>>>>>> *sigh*
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>>>>> On Aug 10, 2009, at 4:05 PM, Carlos André wrote:
>>>>>>>>>>>> Something funny: Using default tcp_syn_retries (5) i got
>>>>>>>>>>>> "3,6,12,24,48,96" secs interval... but if i change  
>>>>>>>>>>>> tcp_syn_retries to
>>>>>>>>>>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>>>>>>>>>> Right.  Normally the RPC client calls the kernel's socket  
>>>>>>>>>>> connect
>>>>>>>>>>> function,
>>>>>>>>>>> which does 6 SYN retries.  That one call usually takes  
>>>>>>>>>>> longer than
>>>>>>>>>>> the RPC
>>>>>>>>>>> client's connect timeout, so it only makes one connect  
>>>>>>>>>>> call, and then
>>>>>>>>>>> fails.
>>>>>>>>>>>
>>>>>>>>>>> Reducing the number of SYN retries per connect attempt  
>>>>>>>>>>> causes the RPC
>>>>>>>>>>> client
>>>>>>>>>>> to retry the connect call until its connect timeout  
>>>>>>>>>>> expires.  Each
>>>>>>>>>>> connect
>>>>>>>>>>> call resets the SYN timeout to 3 seconds.
>>>>>>>>>>>
>>>>>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t  
>>>>>>>>>>>> nfs4 -o
>>>>>>>>>>>> sec=krb5p,proto=tcp
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (giving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real    3m9.000s
>>>>>>>>>>>> user    0m0.000s
>>>>>>>>>>>> sys     0m0.002s
>>>>>>>>>>>>
>>>>>>>>>>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/ 
>>>>>>>>>>>> tcp_syn_retries
>>>>>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t  
>>>>>>>>>>>> nfs4 -o
>>>>>>>>>>>> sec=krb5p,proto=tcp  ("retry=1" = no change)
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (retrying).
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out  
>>>>>>>>>>>> (giving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real    2m6.004s
>>>>>>>>>>>> user    0m0.000s
>>>>>>>>>>>> sys     0m0.004s
>>>>>>>>>>>>
>>>>>>>>>>>> (3,6,3,6... secs interval)
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> 2009/8/10 Carlos André <candrecn@gmail.com>:
>>>>>>>>>>>>> No, i'm just using packages from CentOS repo...
>>>>>>>>>>>>>
>>>>>>>>>>>>> And u're right about expo retries... with tcpdump i've  
>>>>>>>>>>>>> monitored
>>>>>>>>>>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96  
>>>>>>>>>>>>> secs on port
>>>>>>>>>>>>> 2049...
>>>>>>>>>>>>> I tried use "retry=1" option on mount without any  
>>>>>>>>>>>>> change... I dont
>>>>>>>>>>>>> want change source or tcp timers... just NFSv4 client.
>>>>>>>>>>>>>
>>>>>>>>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>>>>>>>> On Aug 10, 2009, at 2:29 PM, Carlos André wrote:
>>>>>>>>>>>>>>> Bruce, no... you're right.  I'm describing a situation  
>>>>>>>>>>>>>>> where my
>>>>>>>>>>>>>>> server
>>>>>>>>>>>>>>> died... i need mount fail faster (10 or 15 secs max)  
>>>>>>>>>>>>>>> than 3 minutes
>>>>>>>>>>>>>>> and 9 seconds...
>>>>>>>>>>>>>> The 189 second timeout is likely how long it takes the  
>>>>>>>>>>>>>> kernel to
>>>>>>>>>>>>>> give up
>>>>>>>>>>>>>> trying to connect a TCP socket to the server (6 SYN  
>>>>>>>>>>>>>> attempts with
>>>>>>>>>>>>>> exponential retries, or something like that).  For  
>>>>>>>>>>>>>> stock CentOS
>>>>>>>>>>>>>> 5.3, I
>>>>>>>>>>>>>> think
>>>>>>>>>>>>>> user space does only a DNS lookup for normal NFSv4  
>>>>>>>>>>>>>> mounts -- the
>>>>>>>>>>>>>> kernel
>>>>>>>>>>>>>> just
>>>>>>>>>>>>>> tries to connect a TCP socket to port 2049, with no  
>>>>>>>>>>>>>> preceding rpcbind
>>>>>>>>>>>>>> request.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Carlos, let us know if you have replaced any NFS- 
>>>>>>>>>>>>>> related CentOS
>>>>>>>>>>>>>> components
>>>>>>>>>>>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>>>>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny  
>>>>>>>>>>>>>>>> Halevy wrote:
>>>>>>>>>>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos André <candrecn@gmail.com 
>>>>>>>>>>>>>>>>> >
>>>>>>>>>>>>>>>>> wrote:
>>>>>>>>>>>>>>>>>> Anyone ?
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>> 2009/7/29 Carlos André <candrecn@gmail.com>:
>>>>>>>>>>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4  
>>>>>>>>>>>>>>>>>>> server to work with
>>>>>>>>>>>>>>>>>>> Kerberos
>>>>>>>>>>>>>>>>>>> and AutoFS, but i got a problem: If NFS server  
>>>>>>>>>>>>>>>>>>> goes down i get a
>>>>>>>>>>>>>>>>>>> LOOOOOOONG
>>>>>>>>>>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4  
>>>>>>>>>>>>>>>>>>> client...
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> Since i need mount some (3 to 6) dirs at user  
>>>>>>>>>>>>>>>>>>> logon process, if
>>>>>>>>>>>>>>>>>>> mount
>>>>>>>>>>>>>>>>>>> hangs,
>>>>>>>>>>>>>>>>>>> user logon hangs. Then i want configure it to  
>>>>>>>>>>>>>>>>>>> timeout (if server
>>>>>>>>>>>>>>>>>>> down)
>>>>>>>>>>>>>>>>>>> after
>>>>>>>>>>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> I already make a lab and tried a LOT of  
>>>>>>>>>>>>>>>>>>> combinations, there my
>>>>>>>>>>>>>>>>>>> findings
>>>>>>>>>>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP:  
>>>>>>>>>>>>>>>>>>> 172.16.1.10) using
>>>>>>>>>>>>>>>>>>> basic
>>>>>>>>>>>>>>>>>>> command
>>>>>>>>>>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t  
>>>>>>>>>>>>>>>>>>> nfs4 -o
>>>>>>>>>>>>>>>>>>> sec=krb5,proto=<tcp/udp>) from NFS client:
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> - Once i try access mount point using AutoFS  
>>>>>>>>>>>>>>>>>>> (proto=tcp OR
>>>>>>>>>>>>>>>>>>> proto=udp)
>>>>>>>>>>>>>>>>>>> it
>>>>>>>>>>>>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until  
>>>>>>>>>>>>>>>>>>> show error
>>>>>>>>>>>>>>>>>>> (mount:
>>>>>>>>>>>>>>>>>>> mount to
>>>>>>>>>>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving  
>>>>>>>>>>>>>>>>>>> up))
>>>>>>>>>>>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>>>>>>>>>>> I thought he was describing a situation where the  
>>>>>>>>>>>>>>>> server the server
>>>>>>>>>>>>>>>> is completely gone and isn't coming back, and  
>>>>>>>>>>>>>>>> wondering how to make
>>>>>>>>>>>>>>>> the
>>>>>>>>>>>>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> --b.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> --
>>>>>>>>>>>>>>> To unsubscribe from this list: send the line  
>>>>>>>>>>>>>>> "unsubscribe
>>>>>>>>>>>>>>> linux-nfs" in
>>>>>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>>>>>> --
>>>>>>>>>>>>>> Chuck Lever
>>>>>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>> --
>>>>>>>>>>> Chuck Lever
>>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>> --
>>>>>>>>> Chuck Lever
>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>
>>>>
>>>>
>>>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



