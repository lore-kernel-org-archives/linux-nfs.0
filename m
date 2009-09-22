From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Tue, 22 Sep 2009 14:52:13 -0300
Message-ID: <f6ce31e30909221052m761a20b2s6443b436e748e5ac@mail.gmail.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	 <f6ce31e30908120800i2cc82005s695d1097df554b58@mail.gmail.com>
	 <4A82DDB1.1000109@redhat.com>
	 <f6ce31e30908120940m6e9a093ayc59d7ef98e37b3d0@mail.gmail.com>
	 <4A84210F.3020906@redhat.com>
	 <f6ce31e30908130743l78423b52je5aaeaaf3ed1a373@mail.gmail.com>
	 <f6ce31e30908130818r2ccd676ax174eb5062282a15b@mail.gmail.com>
	 <1250555418.16878.7.camel@zeus.themaw.net>
	 <f6ce31e30908240627gff0a7eeu3c884185e6324518@mail.gmail.com>
	 <4AB864CD.5090307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Ian Kent <ikent@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:61114 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143AbZIVRwL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2009 13:52:11 -0400
Received: by fxm18 with SMTP id 18so1015004fxm.17
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2009 10:52:14 -0700 (PDT)
In-Reply-To: <4AB864CD.5090307@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok then, i'll be waiting for patch :)

Thanks a lot.

2009/9/22 Ian Kent <ikent@redhat.com>:
> Carlos Andr=E9 wrote:
>> Hi Ian,
>>
>> Thanks for patch and sorry for delay (i'm expecting receive u reply =
on
>> bug track, not here) :)
>>
>> But, this patch doesnt worked to me like expected... =A0:(
>
> OK, I've been off on a wild goose chase, thinking this was related to
> the moving of the mount option handling and initial file handle open
> into the kernel, but that isn't even included in the kernel you are
> using. Suffice it to say this behaviour exists at least back to RHEL-=
4
> and NFS v3 and v2 mount take around 1 minute to time out and v4 about=
 3
> minutes. Not only that, mount attempts from the command line appear t=
o
> respond to an TERM signal, including using a relatively recent kernel=
,
> but I might not have that quite right.
>
> Anyway, now that I'm back on track, we might make some progress.
>
>>
>>
>> Firstly I've changed "#MOUNT_WAIT=3D-1" to "MOUNT_WAIT=3D10"
>> and later changed "10" to "2" with same results...
>> (always restarting service, of course :)
>>
>> Then, tried remove "sec=3Dkrb5p", and later removed "nfs4" but i got
>> same results again.
>>
>> Or i'm doing something wrong?
>
> Maybe.
>
> I've tested this out now with some interesting results.
> I can't easily setup Kerberos for NFS so lets work on plain mounts to
> begin with.
>
> Using the patch I posted with plain mounts autofs did indeed return
> after the configured timeout. After sending the TERM signal to the mo=
unt
> the mount process went away but the mount.nfs child process remained
> waiting for to timeout. User space received the usual ENOENT error af=
ter
> the configured timeout. The same occurred with nfs4. This is much the
> same as the timed umount behaviour so it's expected.
>
> So, there must be something wrong with the patching of autofs.
> I'll put together a patched RHEL package and we will continue this in
> the RedHat bug you've logged.
>
>>
>>
>> [root@KSTATION areas]# automount -V
>>
>> Linux automount version 5.0.1-0.rc2.131.bz517349.1
>> [...]
>>
>> [root@KSTATION areas]# time ls -la testdown
>> ls: testedown: No such file or directory
>>
>> real =A0 =A03m9.006s
>> user =A0 =A00m0.002s
>> sys =A0 =A0 0m0.000s
>>
>>
>> LOGGING:
>> -----------------------------------------
>> Aug 24 09:23:51 KSTATION automount[20803]: mount_mount: mount(nfs):
>> calling mount -t nfs4 -s -o rw,acl,sec=3Dkrb5p 1.2.3.4:/areas/testdo=
wn
>> /misc/areas/testdown
>> Aug 24 09:27:00 KSTATION automount[20803]: mount(nfs): nfs: mount
>> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
>> Aug 24 09:27:00 KSTATION automount[20803]: ioctl_send_fail: token =3D=
 91
>> Aug 24 09:27:00 KSTATION automount[20803]: failed to mount /misc/are=
as/testdown
>> -----------------------------------------
>>
>>
>>
>>
>>
>> 2009/8/17 Ian Kent <ikent@redhat.com>:
>>> On Thu, 2009-08-13 at 12:18 -0300, Carlos Andr=E9 wrote:
>>>> Filled bug report:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D517349
>>> Hi Carlos,
>>>
>>> I have a patched source rpm to add a mount wait parameter to autofs
>>> located at:
>>> http://people.redhat.com/~ikent/autofs-5.0.1-0.rc2.131.bz517349.1
>>>
>>> Could you build it and see if it works.
>>> I haven't tested it at all but it is fairly straight forward.
>>> It is still unclear if this is the right way to do this and what th=
e
>>> consequences are in sending a term signal to mount. This mount requ=
est
>>> will likely be followed by other requests for the same mount causin=
g an
>>> accumulation of mount(8) processes waiting for RPC timeouts before =
they
>>> can answer the TERM signal.
>>>
>>> Anyway, for information the patch included in the source rpm above =
is:
>>>
>>> autofs-5.0.4 - add mount wait parameter
>>>
>>> From: Ian Kent <raven@themaw.net>
>>>
>>> Often delays when trying to mount from a server that is not repondi=
ng
>>> for some reason are undesirable. To try and prevent these delays we
>>> provide a configuration setting to limit the time that we wait for
>>> our spawned mount(8) process to complete before sending it a SIGTER=
M
>>> signal. This patch adds a configuration parameter to allow us to
>>> request we limit the time we wait for mount(8) to complete before
>>> send it a TERM signal.
>>> ---
>>>
>>> =A0daemon/spawn.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 ++-
>>> =A0include/defaults.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 ++
>>> =A0lib/defaults.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 13 ++++++++=
+++++
>>> =A0man/auto.master.5.in =A0 =A0 =A0 =A0 =A0 | =A0 =A07 +++++++
>>> =A0redhat/autofs.sysconfig.in =A0 =A0 | =A0 =A09 +++++++++
>>> =A0samples/autofs.conf.default.in | =A0 =A09 +++++++++
>>> =A06 files changed, 42 insertions(+), 1 deletion(-)
>>>
>>>
>>> --- autofs-5.0.1.orig/daemon/spawn.c
>>> +++ autofs-5.0.1/daemon/spawn.c
>>> @@ -312,6 +312,7 @@ int spawn_mount(unsigned logopt, ...)
>>> =A0 =A0 =A0 =A0unsigned int options;
>>> =A0 =A0 =A0 =A0unsigned int retries =3D MTAB_LOCK_RETRIES;
>>> =A0 =A0 =A0 =A0int update_mtab =3D 1, ret, printed =3D 0;
>>> + =A0 =A0 =A0 unsigned int wait =3D defaults_get_mount_wait();
>>> =A0 =A0 =A0 =A0char buf[PATH_MAX];
>>>
>>> =A0 =A0 =A0 =A0/* If we use mount locking we can't validate the loc=
ation */
>>> @@ -353,7 +354,7 @@ int spawn_mount(unsigned logopt, ...)
>>> =A0 =A0 =A0 =A0va_end(arg);
>>>
>>> =A0 =A0 =A0 =A0while (retries--) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D do_spawn(logopt, -1, options,=
 prog, (const char **) argv);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D do_spawn(logopt, wait, option=
s, prog, (const char **) argv);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret & MTAB_NOTUPDATED) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct timespec tm =3D=
 {3, 0};
>>>
>>> --- autofs-5.0.1.orig/include/defaults.h
>>> +++ autofs-5.0.1/include/defaults.h
>>> @@ -24,6 +24,7 @@
>>>
>>> =A0#define DEFAULT_TIMEOUT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0600
>>> =A0#define DEFAULT_NEGATIVE_TIMEOUT =A0 =A0 =A0 60
>>> +#define DEFAULT_MOUNT_WAIT =A0 =A0 =A0 =A0 =A0 =A0 -1
>>> =A0#define DEFAULT_UMOUNT_WAIT =A0 =A0 =A0 =A0 =A0 =A012
>>> =A0#define DEFAULT_BROWSE_MODE =A0 =A0 =A0 =A0 =A0 =A01
>>> =A0#define DEFAULT_LOGGING =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A00
>>> @@ -62,6 +63,7 @@ struct ldap_schema *defaults_get_schema(
>>> =A0struct ldap_searchdn *defaults_get_searchdns(void);
>>> =A0void defaults_free_searchdns(struct ldap_searchdn *);
>>> =A0unsigned int defaults_get_append_options(void);
>>> +unsigned int defaults_get_mount_wait(void);
>>> =A0unsigned int defaults_get_umount_wait(void);
>>> =A0const char *defaults_get_auth_conf_file(void);
>>> =A0unsigned int defaults_get_map_hash_table_size(void);
>>> --- autofs-5.0.1.orig/lib/defaults.c
>>> +++ autofs-5.0.1/lib/defaults.c
>>> @@ -45,6 +45,7 @@
>>> =A0#define ENV_NAME_VALUE_ATTR =A0 =A0 =A0 =A0 =A0 =A0"VALUE_ATTRIB=
UTE"
>>>
>>> =A0#define ENV_APPEND_OPTIONS =A0 =A0 =A0 =A0 =A0 =A0 "APPEND_OPTIO=
NS"
>>> +#define ENV_MOUNT_WAIT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MOUNT_WAIT=
"
>>> =A0#define ENV_UMOUNT_WAIT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0"UMOUNT_WAIT"
>>> =A0#define ENV_AUTH_CONF_FILE =A0 =A0 =A0 =A0 =A0 =A0 "AUTH_CONF_FI=
LE"
>>>
>>> @@ -323,6 +324,7 @@ unsigned int defaults_read_config(unsign
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_NAME_ENTRY_ATTR, value, to_syslog) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_NAME_VALUE_ATTR, value, to_syslog) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_APPEND_OPTIONS, value, to_syslog) ||
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 check_set_config_value(key, E=
NV_MOUNT_WAIT, value, to_syslog) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_UMOUNT_WAIT, value, to_syslog) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_AUTH_CONF_FILE, value, to_syslog) ||
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_set_config_value(key, =
ENV_MAP_HASH_TABLE_SIZE, value, to_syslog))
>>> @@ -652,6 +654,17 @@ unsigned int defaults_get_append_options
>>> =A0 =A0 =A0 =A0return res;
>>> =A0}
>>>
>>> +unsigned int defaults_get_mount_wait(void)
>>> +{
>>> + =A0 =A0 =A0 long wait;
>>> +
>>> + =A0 =A0 =A0 wait =3D get_env_number(ENV_MOUNT_WAIT);
>>> + =A0 =A0 =A0 if (wait < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D DEFAULT_MOUNT_WAIT;
>>> +
>>> + =A0 =A0 =A0 return (unsigned int) wait;
>>> +}
>>> +
>>> =A0unsigned int defaults_get_umount_wait(void)
>>> =A0{
>>> =A0 =A0 =A0 =A0long wait;
>>> --- autofs-5.0.1.orig/man/auto.master.5.in
>>> +++ autofs-5.0.1/man/auto.master.5.in
>>> @@ -175,6 +175,13 @@ Set the default timeout for caching fail
>>> =A060). If the equivalent command line option is given it will over=
ride this
>>> =A0setting.
>>> =A0.TP
>>> +.B MOUNT_WAIT
>>> +Set the default time to wait for a response from a spawned mount(8=
)
>>> +before sending it a SIGTERM. Note that we still need to wait for t=
he
>>> +RPC layer to timeout before the sub-process exits so this isn't id=
eal
>>> +but it is the best we can do. The default is to wait until mount(8=
)
>>> +returns without intervention.
>>> +.TP
>>> =A0.B UMOUNT_WAIT
>>> =A0Set the default time to wait for a response from a spawned umoun=
t(8)
>>> =A0before sending it a SIGTERM. Note that we still need to wait for=
 the
>>> --- autofs-5.0.1.orig/redhat/autofs.sysconfig.in
>>> +++ autofs-5.0.1/redhat/autofs.sysconfig.in
>>> @@ -14,6 +14,15 @@ TIMEOUT=3D300
>>> =A0#
>>> =A0#NEGATIVE_TIMEOUT=3D60
>>> =A0#
>>> +# MOUNT_WAIT - time to wait for a response from umount(8).
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 Setting this timeout can cause problems =
when
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 mount would otherwise wait for a server =
that
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 is temporarily unavailable, such as when=
 it's
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 restarting. The defailt of waiting for m=
ount(8)
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 usually results in a wait of around 3 mi=
nutes.
>>> +#
>>> +#MOUNT_WAIT=3D-1
>>> +#
>>> =A0# UMOUNT_WAIT - time to wait for a response from umount(8).
>>> =A0#
>>> =A0#UMOUNT_WAIT=3D12
>>> --- autofs-5.0.1.orig/samples/autofs.conf.default.in
>>> +++ autofs-5.0.1/samples/autofs.conf.default.in
>>> @@ -14,6 +14,15 @@ TIMEOUT=3D300
>>> =A0#
>>> =A0#NEGATIVE_TIMEOUT=3D60
>>> =A0#
>>> +# MOUNT_WAIT - time to wait for a response from umount(8).
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 Setting this timeout can cause problems =
when
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 mount would otherwise wait for a server =
that
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 is temporarily unavailable, such as when=
 it's
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 restarting. The defailt of waiting for m=
ount(8)
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 usually results in a wait of around 3 mi=
nutes.
>>> +#
>>> +#MOUNT_WAIT=3D-1
>>> +#
>>> =A0# UMOUNT_WAIT - time to wait for a response from umount(8).
>>> =A0#
>>> =A0#UMOUNT_WAIT=3D12
>>>
>>>
>>>> Thanks!
>>>>
>>>> 2009/8/13 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>> 2009/8/13 Ian Kent <ikent@redhat.com>:
>>>>>> Carlos Andr=E9 wrote:
>>>>>>> Today (2009-08-12) I'm using:
>>>>>>> kernel-2.6.18-128.2.1.el5
>>>>>>> autofs-5.0.1-0.rc2.102.el5_3.1
>>>>>> Thanks,
>>>>>>
>>>>>> My mistake, the wait time I was referring to is used for umounts=
 during
>>>>>> expires and is present in rev rc2.102.
>>>>>>
>>>>>> It shouldn't be hard to add this for mount as well.
>>>>>> Would you like me to put something together?
>>>>> Sure! that 'll help me a lot (and for sure another ppl) :) Thanks=
 :)
>>>>>
>>>>>> Probably would be good to test something out to see if we can ma=
ke a
>>>>>> difference with the killing mount after some configured timeout =
but, if
>>>>>> we make progress, probably the best way to deal with it is for y=
ou to
>>>>>> log a bug against rhel-5 so I can get it committed to the rhel p=
ackage.
>>>>>> The possible issue is that I'm not sure if the RPC subsystem in =
the
>>>>>> above rhel kernel will respond well to process death with potent=
ial
>>>>>> outstanding requests. But we'll see.
>>>>> Ok, on my way :)
>>>>>
>>>>> Thanks a lot!
>>>>>
>>>>>>>
>>>>>>> Look my last test:
>>>>>>> --------------------------------------------------------------
>>>>>>> [root@KSTATION areas]# time ls testdown
>>>>>>> ls: testdown: No such file or directory
>>>>>>>
>>>>>>> real =A0 =A03m9.025s
>>>>>>> user =A0 =A00m0.000s
>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: sun_mount: parse(sun=
):
>>>>>>> mounting root /misc/areas, mountpoint testdown, what
>>>>>>> 1.2.3.4:/areas/testdown, fstype nfs4, options
>>>>>>> acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: do_mount:
>>>>>>> 1.2.3.4:/areas/testdown /misc/areas/testdown type nfs4 options
>>>>>>> acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0 using module nfs4
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(n=
fs):
>>>>>>> root=3D/misc/areas name=3Dtestdown what=3D1.2.3.4:/areas/testdo=
wn,
>>>>>>> fstype=3Dnfs4, options=3Dacl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(n=
fs):
>>>>>>> nfs options=3D"acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0", nosymlin=
k=3D0, ro=3D0
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(n=
fs):
>>>>>>> calling mkdir_path /misc/areas/testdown
>>>>>>> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(n=
fs):
>>>>>>> calling mount -t nfs4 -s -o acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D=
0
>>>>>>> 1.2.3.4:/areas/testdown /misc/areas/testdown
>>>>>>> Aug 12 12:58:12 KSTATION automount[15471]: st_expire: state 1 p=
ath /misc
>>>>>>> Aug 12 12:58:12 KSTATION automount[15471]: expire_proc: exp_pro=
c =3D
>>>>>>> 3078093712 path /misc
>>>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_proc_indirect=
: 2
>>>>>>> submounts remaining in /misc
>>>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup: got =
thid
>>>>>>> 3078093712 path /misc stat 3
>>>>>>> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup: sigc=
hld:
>>>>>>> exp 3078093712 finished, switching from 2 to 1
>>>>>>> Aug 12 12:58:13 KSTATION automount[15471]: st_ready: st_ready()=
: state
>>>>>>> =3D 2 path /misc
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: st_expire: state 1 p=
ath /misc
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc: exp_pro=
c =3D
>>>>>>> 3078093712 path /misc
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc_indirect=
: 2
>>>>>>> submounts remaining in /misc
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup: got =
thid
>>>>>>> 3078093712 path /misc stat 3
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup: sigc=
hld:
>>>>>>> exp 3078093712 finished, switching from 2 to 1
>>>>>>> Aug 12 12:59:28 KSTATION automount[15471]: st_ready: st_ready()=
: state
>>>>>>> =3D 2 path /misc
>>>>>>> Aug 12 13:00:16 KSTATION automount[15471]: >> mount: mount to N=
=46S
>>>>>>> server '1.2.3.4' failed: timed out (giving up).
>>>>>>> Aug 12 13:00:16 KSTATION automount[15471]: mount(nfs): nfs: mou=
nt
>>>>>>> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
>>>>>>> Aug 12 13:00:16 KSTATION automount[15471]: send_fail: token =3D=
 17
>>>>>>> Aug 12 13:00:16 KSTATION automount[15471]: failed to mount /mis=
c/areas/testdown
>>>>>>> Aug 12 13:00:43 KSTATION automount[15471]: st_expire: state 1 p=
ath /misc
>>>>>>> --------------------------------------------------------------
>>>>>>>
>>>>>>> 2009/8/12 Ian Kent <ikent@redhat.com>:
>>>>>>>> Carlos Andr=E9 wrote:
>>>>>>>>> Hi Ian,
>>>>>>>>> I'm getting crazy trying put "retry=3D" to work on mount... t=
his option
>>>>>>>>> just DONT WORK if use proto=3Dtcp and/OR kerberos (sec=3Dkrb5=
/krb5i/krb5p)
>>>>>>>>> like you can see on my previous emails...
>>>>>>>> Right, my mistake for not looking closely enough at post.
>>>>>>>>
>>>>>>>> Maybe this is related to the same sort of problem we had with =
mount in
>>>>>>>> the past, before the options parsing went into the kernel, whe=
re other
>>>>>>>> services, like portmapper (or rpcbind), were being done with d=
ifferent
>>>>>>>> timeout parameters before the RPC calls for mounting. That's j=
ust an
>>>>>>>> example as NFSv4 shouldn't be sensitive to portmapper anyway.
>>>>>>>>
>>>>>>>> But what version of autofs and kernel did you say you were usi=
ng?
>>>>>>>>
>>>>>>>>> I appreciate any help.
>>>>>>>>>
>>>>>>>>> Carlos.
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> 2009/8/12 Ian Kent <ikent@redhat.com>:
>>>>>>>>>> Chuck Lever wrote:
>>>>>>>>>>> On Aug 11, 2009, at 8:41 AM, Carlos Andr=E9 wrote:
>>>>>>>>>>>> This long timeout is good if workstation need mount a crit=
ical
>>>>>>>>>>>> directory using /etc/fstab on boot (for example)..
>>>>>>>>>>>> But in my case, using this loooong timeout doesnt make any=
 sense,
>>>>>>>>>>>> since autofs retry mount directory on-access. This in fact=
 gives me
>>>>>>>>>>>> alot of headaches, coz user login 'll just hangs if one se=
rver goes
>>>>>>>>>>>> down for any reason, and will again hangs if user try acce=
ss directory
>>>>>>>>>>>> pointing to a NFS down server...
>>>>>>>>>>> "retry=3D0" means the mount command will fail as soon as th=
e first
>>>>>>>>>>> mount(2) system call fails. =A0When you set SYN retries to =
1, this means
>>>>>>>>>>> after 9 seconds, the connect fails, and that causes the mou=
nt(2) system
>>>>>>>>>>> call to fail.
>>>>>>>>>>>
>>>>>>>>>>> Recent conversations with Ian suggested that a long timeout=
 was desired
>>>>>>>>>>> for automounter as well as other cases. =A0Ian, is there so=
mething else we
>>>>>>>>>>> need to consider to determine the correct retry timeout for=
 NFS/TCP
>>>>>>>>>>> mount points handled via automounter? =A0How should mount.n=
fs wait so we
>>>>>>>>>>> don't make other use cases worse? =A0(Looks like most of th=
e history is
>>>>>>>>>>> intact below).
>>>>>>>>>> Of course we know that autofs is entirely at the mercy of mo=
unt(8) (and
>>>>>>>>>> mount.nfs in particular). This has always been a difficult s=
ituation for
>>>>>>>>>> the automounter because interactive mount invocations should=
 wait. But I
>>>>>>>>>> believe automount mounts should always time out quickly, but=
 that leads
>>>>>>>>>> to its own set of problems, especially when home directories=
 are concerned.
>>>>>>>>>>
>>>>>>>>>> I think adding "retry=3D0" is the right thing to do myself b=
ut I'm not
>>>>>>>>>> certain that will work as we expect. I'll have to do some ex=
perimentation.
>>>>>>>>>>
>>>>>>>>>>> How long do you think is appropriate for the automounter to=
 wait if the
>>>>>>>>>>> server is down, in your case, Carlos?
>>>>>>>>>>>
>>>>>>>>>>>> Am losing something or there have was something weirdo...!=
?
>>>>>>>>>>>> ------------------------------------------------
>>>>>>>>>>>> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_ret=
ries =A0[DEFAULT]
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> proto=3Dtcp,retry=3D1
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A03m9.000s
>>>>>>>>>>>> user =A0 =A00m0.002s
>>>>>>>>>>>> sys =A0 =A0 0m0.001s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A03m9.000s
>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> proto=3Dtcp,retry=3D0
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A03m9.001s
>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>> sys =A0 =A0 0m0.003s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A03m9.001s
>>>>>>>>>>>> user =A0 =A00m0.002s
>>>>>>>>>>>> sys =A0 =A0 0m0.001s
>>>>>>>>>>>>
>>>>>>>>>>>> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_ret=
ries [ 5 to 1 ]
>>>>>>>>>>>>
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> proto=3Dtcp,retry=3D1
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (re=
trying). [x 6]
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A01m3.002s
>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (re=
trying). [x 13]
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A02m6.000s
>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> proto=3Dtcp,retry=3D0
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A00m9.003s
>>>>>>>>>>>> user =A0 =A00m0.001s
>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs=
4 -o
>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (re=
trying). [x 13]
>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (gi=
ving up).
>>>>>>>>>>>>
>>>>>>>>>>>> real =A0 =A02m6.001s
>>>>>>>>>>>> user =A0 =A00m0.001s
>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>> [root@KSTATION ~]#
>>>>>>>>>>>> ------------------------------------------------
>>>>>>>>>>>> max timeout goes to 2m6s changing tcp_syn_retries from 5 t=
o 1... and
>>>>>>>>>>>> using retry=3D0 without kerberos I got only 9s...
>>>>>>>>>>>>
>>>>>>>>>>>> *sigh*
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>>>>>>> On Aug 10, 2009, at 4:05 PM, Carlos Andr=E9 wrote:
>>>>>>>>>>>>>> Something funny: Using default tcp_syn_retries (5) i got
>>>>>>>>>>>>>> "3,6,12,24,48,96" secs interval... but if i change tcp_s=
yn_retries to
>>>>>>>>>>>>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>>>>>>>>>>>> Right. =A0Normally the RPC client calls the kernel's sock=
et connect
>>>>>>>>>>>>> function,
>>>>>>>>>>>>> which does 6 SYN retries. =A0That one call usually takes =
longer than
>>>>>>>>>>>>> the RPC
>>>>>>>>>>>>> client's connect timeout, so it only makes one connect ca=
ll, and then
>>>>>>>>>>>>> fails.
>>>>>>>>>>>>>
>>>>>>>>>>>>> Reducing the number of SYN retries per connect attempt ca=
uses the RPC
>>>>>>>>>>>>> client
>>>>>>>>>>>>> to retry the connect call until its connect timeout expir=
es. =A0Each
>>>>>>>>>>>>> connect
>>>>>>>>>>>>> call resets the SYN timeout to 3 seconds.
>>>>>>>>>>>>>
>>>>>>>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t n=
fs4 -o
>>>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
giving up).
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> real =A0 =A03m9.000s
>>>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>>>> sys =A0 =A0 0m0.002s
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_re=
tries
>>>>>>>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t n=
fs4 -o
>>>>>>>>>>>>>> sec=3Dkrb5p,proto=3Dtcp =A0("retry=3D1" =3D no change)
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
retrying).
>>>>>>>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (=
giving up).
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> real =A0 =A02m6.004s
>>>>>>>>>>>>>> user =A0 =A00m0.000s
>>>>>>>>>>>>>> sys =A0 =A0 0m0.004s
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> (3,6,3,6... secs interval)
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> 2009/8/10 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>>>>>>>> No, i'm just using packages from CentOS repo...
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> And u're right about expo retries... with tcpdump i've =
monitored
>>>>>>>>>>>>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 s=
ecs on port
>>>>>>>>>>>>>>> 2049...
>>>>>>>>>>>>>>> I tried use "retry=3D1" option on mount without any cha=
nge... I dont
>>>>>>>>>>>>>>> want change source or tcp timers... just NFSv4 client.
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>>>>>>>>>> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>>>>>>>>>>>>>>>> Bruce, no... you're right. =A0I'm describing a situat=
ion where my
>>>>>>>>>>>>>>>>> server
>>>>>>>>>>>>>>>>> died... i need mount fail faster (10 or 15 secs max) =
than 3 minutes
>>>>>>>>>>>>>>>>> and 9 seconds...
>>>>>>>>>>>>>>>> The 189 second timeout is likely how long it takes the=
 kernel to
>>>>>>>>>>>>>>>> give up
>>>>>>>>>>>>>>>> trying to connect a TCP socket to the server (6 SYN at=
tempts with
>>>>>>>>>>>>>>>> exponential retries, or something like that). =A0For s=
tock CentOS
>>>>>>>>>>>>>>>> 5.3, I
>>>>>>>>>>>>>>>> think
>>>>>>>>>>>>>>>> user space does only a DNS lookup for normal NFSv4 mou=
nts -- the
>>>>>>>>>>>>>>>> kernel
>>>>>>>>>>>>>>>> just
>>>>>>>>>>>>>>>> tries to connect a TCP socket to port 2049, with no pr=
eceding rpcbind
>>>>>>>>>>>>>>>> request.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Carlos, let us know if you have replaced any NFS-relat=
ed CentOS
>>>>>>>>>>>>>>>> components
>>>>>>>>>>>>>>>> (kernel, nfs-utils) with something you've built yourse=
lf.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>>>>>>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Hale=
vy wrote:
>>>>>>>>>>>>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candr=
ecn@gmail.com>
>>>>>>>>>>>>>>>>>>> wrote:
>>>>>>>>>>>>>>>>>>>> Anyone ?
>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>>>>>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 serv=
er to work with
>>>>>>>>>>>>>>>>>>>>> Kerberos
>>>>>>>>>>>>>>>>>>>>> and AutoFS, but i got a problem: If NFS server go=
es down i get a
>>>>>>>>>>>>>>>>>>>>> LOOOOOOONG
>>>>>>>>>>>>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 clien=
t...
>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>> Since i need mount some (3 to 6) dirs at user log=
on process, if
>>>>>>>>>>>>>>>>>>>>> mount
>>>>>>>>>>>>>>>>>>>>> hangs,
>>>>>>>>>>>>>>>>>>>>> user logon hangs. Then i want configure it to tim=
eout (if server
>>>>>>>>>>>>>>>>>>>>> down)
>>>>>>>>>>>>>>>>>>>>> after
>>>>>>>>>>>>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>> I already make a lab and tried a LOT of combinati=
ons, there my
>>>>>>>>>>>>>>>>>>>>> findings
>>>>>>>>>>>>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.=
1.10) using
>>>>>>>>>>>>>>>>>>>>> basic
>>>>>>>>>>>>>>>>>>>>> command
>>>>>>>>>>>>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t =
nfs4 -o
>>>>>>>>>>>>>>>>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>> - Once i try access mount point using AutoFS (pro=
to=3Dtcp OR
>>>>>>>>>>>>>>>>>>>>> proto=3Dudp)
>>>>>>>>>>>>>>>>>>>>> it
>>>>>>>>>>>>>>>>>>>>> hangs for 189 secs (3m9s: real =A03m9.001s) =A0un=
til show error
>>>>>>>>>>>>>>>>>>>>> (mount:
>>>>>>>>>>>>>>>>>>>>> mount to
>>>>>>>>>>>>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (givin=
g up))
>>>>>>>>>>>>>>>>>>> Sounds like you're hitting the server's grace perio=
d.
>>>>>>>>>>>>>>>>>> I thought he was describing a situation where the se=
rver the server
>>>>>>>>>>>>>>>>>> is completely gone and isn't coming back, and wonder=
ing how to make
>>>>>>>>>>>>>>>>>> the
>>>>>>>>>>>>>>>>>> mount fail faster. =A0But I may be misunderstanding.
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>> --b.
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> --
>>>>>>>>>>>>>>>>> To unsubscribe from this list: send the line "unsubsc=
ribe
>>>>>>>>>>>>>>>>> linux-nfs" in
>>>>>>>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>>>>>>>> More majordomo info at =A0http://vger.kernel.org/majo=
rdomo-info.html
>>>>>>>>>>>>>>>> --
>>>>>>>>>>>>>>>> Chuck Lever
>>>>>>>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>> --
>>>>>>>>>>>>> Chuck Lever
>>>>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>> --
>>>>>>>>>>> Chuck Lever
>>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>
>>>
>
>
